import os
import random
import time
from datetime import datetime, timedelta
from azure.cosmos import CosmosClient, PartitionKey

# Configuration (Loaded from Environment Variables injected by Terraform)
ENDPOINT = os.environ.get("COSMOS_ENDPOINT")
KEY = os.environ.get("COSMOS_KEY")
DATABASE_NAME = "WeatherDB"
CONTAINER_NAME = "WeatherContainer"

def get_container():
    client = CosmosClient(ENDPOINT, KEY)
    database = client.get_database_client(DATABASE_NAME)
    return database.get_container_client(CONTAINER_NAME)

def generate_fake_data(region_id):
    """Generates random weather data."""
    now = datetime.utcnow()
    items = []
    for i in range(5):
        timestamp = (now + timedelta(hours=i)).isoformat() + "Z"
        # Unique ID is required in Cosmos DB. We use Region + Time.
        item_id = f"{region_id}_{timestamp}"
        
        item = {
            "id": item_id,
            "RegionID": region_id,
            "SimulationTime": timestamp,
            "Temperature": round(random.uniform(10.0, 35.0), 1),
            "Humidity": random.randint(30, 90),
            "Status": random.choice(['Clear', 'Cloudy', 'Rain'])
        }
        items.append(item)
    return items

def run():
    print("--- Starting Weather Simulation (Azure Cosmos DB) ---")
    container = get_container()
    
    # 1. Generate & Insert Data
    my_region = "EU-West-01"
    data = generate_fake_data(my_region)
    
    print(f"Inserting {len(data)} records...")
    for item in data:
        container.create_item(body=item)
        print(f"Stored: {item['id']}")

    # 2. Query Data
    print(f"\n--- Querying Forecast for {my_region} ---")
    query = "SELECT * FROM c WHERE c.RegionID = @region"
    params = [{"name": "@region", "value": my_region}]
    
    items = container.query_items(query=query, parameters=params, enable_cross_partition_query=False)
    
    for item in items:
        print(f"Time: {item['SimulationTime']} | Temp: {item['Temperature']}C | {item['Status']}")

if __name__ == "__main__":
    run()