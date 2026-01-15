import logging
import os
import azure.functions as func
from azure.ai.vision.imageanalysis import ImageAnalysisClient
from azure.ai.vision.imageanalysis.models import VisualFeatures
from azure.core.credentials import AzureKeyCredential
from azure.cosmos import CosmosClient

app = func.FunctionApp()

@app.blob_trigger(arg_name="myblob", path="uploaded-images/{name}",
                  connection="AzureWebJobsStorage")
def blob_ai_trigger(myblob: func.InputStream):
    logging.info(f"Python Blob trigger processed file: {myblob.name}")

    # 1. Configuration
    vision_endpoint = os.environ["VISION_ENDPOINT"]
    vision_key = os.environ["VISION_KEY"]
    cosmos_endpoint = os.environ["COSMOS_ENDPOINT"]
    cosmos_key = os.environ["COSMOS_KEY"]

    # 2. Analyze Image (Equivalent to Rekognition)
    # Note: We send the raw stream bytes to the Azure Vision API
    client = ImageAnalysisClient(endpoint=vision_endpoint, credential=AzureKeyCredential(vision_key))
    
    # Read the stream content
    image_data = myblob.read()
    
    result = client.analyze(
        image_data=image_data,
        visual_features=[VisualFeatures.TAGS]
    )

    tags = [tag.name for tag in result.tags.list]
    logging.info(f"Detected Tags: {tags}")

    # 3. Save to Cosmos DB (Equivalent to DynamoDB)
    cosmos_client = CosmosClient(cosmos_endpoint, cosmos_key)
    database = cosmos_client.get_database_client("AnalysisDB")
    container = cosmos_client.get_container_client("ImageLabels")

    item = {
        "id": myblob.name.replace("/", "_"), # Unique ID
        "file_name": myblob.name,
        "tags": tags,
        "processed_at": str(os.environ.get("TIME_NOW", "timestamp_placeholder")) 
    }
    
    container.upsert_item(item)
    logging.info("Saved to Database.")