console.log("--> ANALYZER MODULE LOADED <--");

const { BlobServiceClient } = require("@azure/storage-blob");
const ComputerVisionClient =
  require("@azure/cognitiveservices-computervision").ComputerVisionClient;
const ApiKeyCredentials = require("@azure/ms-rest-js").ApiKeyCredentials;

const key = process.env.VISION_KEY;
const endpoint = process.env.VISION_ENDPOINT;
const computerVisionClient = new ComputerVisionClient(
  new ApiKeyCredentials({ inHeader: { "Ocp-Apim-Subscription-Key": key } }),
  endpoint,
);

module.exports = async function (context, myQueueItem) {
  // Azure Functions automatically decodes Base64 queue messages
  const fileName = myQueueItem;
  context.log(`Processing file: ${fileName}`);

  try {
    // 1. Setup Blob Client
    const blobServiceClient = BlobServiceClient.fromConnectionString(
      process.env.STORAGE_CONN_STRING,
    );
    const containerClient = blobServiceClient.getContainerClient(
      process.env.IMAGES_CONTAINER,
    );
    const blobClient = containerClient.getBlobClient(fileName);

    // Check if blob exists before downloading
    if (!(await blobClient.exists())) {
      context.log.error(`File not found: ${fileName}`);
      return;
    }

    // --- FIX STARTS HERE ---
    // Instead of streaming, we download to a Buffer.
    // This satisfies the "ArrayBufferView" requirement of the Vision API.
    const imageBuffer = await blobClient.downloadToBuffer();
    context.log(`Downloaded image. Size: ${imageBuffer.length} bytes`);

    // 2. Send to Azure AI Vision (Read API)
    // readInStream accepts Buffers despite the name
    const initialResponse =
      await computerVisionClient.readInStream(imageBuffer);
    // --- FIX ENDS HERE ---

    // Extract the Operation ID from the 'Operation-Location' header
    const operationId = initialResponse.operationLocation
      .split("/")
      .slice(-1)[0];

    // 3. Poll for results (Explicit Loop)
    let result = { status: "running" };
    while (result.status !== "succeeded" && result.status !== "failed") {
      await new Promise((resolve) => setTimeout(resolve, 1000));
      result = await computerVisionClient.getReadResult(operationId);
      // context.log(`Analysis status: ${result.status}`); // Optional: Comment out to reduce noise
    }

    if (result.status === "failed") {
      throw new Error("Azure AI Vision operation failed.");
    }

    // 4. Process Results (Extract Text and Confidence)
    let fullText = "";
    let totalConfidence = 0;
    let wordCount = 0;

    if (result.analyzeResult && result.analyzeResult.readResults) {
      result.analyzeResult.readResults.forEach((page) => {
        page.lines.forEach((line) => {
          fullText += line.text + "\n";
          if (line.words) {
            line.words.forEach((word) => {
              totalConfidence += word.confidence || 0;
              wordCount++;
            });
          }
        });
      });
    }

    const averageConfidence = wordCount > 0 ? totalConfidence / wordCount : 0;

    const outputData = {
      source_image: fileName,
      detected_text: fullText.trim(),
      metrics: {
        word_count: wordCount,
        average_confidence: averageConfidence.toFixed(4),
      },
      full_api_response: result,
    };

    // 5. Save Results to Blob
    const resultsContainer = blobServiceClient.getContainerClient(
      process.env.RESULTS_CONTAINER,
    );
    await resultsContainer.createIfNotExists();

    const resultBlob = resultsContainer.getBlockBlobClient(`${fileName}.json`);
    await resultBlob.upload(
      JSON.stringify(outputData, null, 2),
      JSON.stringify(outputData).length,
    );

    context.log(
      `Analysis complete. Saved to ${fileName}.json with confidence ${averageConfidence}`,
    );
  } catch (error) {
    context.log.error("Error in Analyzer:", error);
    throw error;
  }
};
