const { BlobServiceClient } = require("@azure/storage-blob");
const { QueueClient } = require("@azure/storage-queue");
const axios = require("axios");
const path = require("path");

module.exports = async function (context, req) {
  const imageUrl = req.body && req.body.url;

  if (!imageUrl) {
    context.res = {
      status: 400,
      body: { error: "Please pass a 'url' in the request body" },
    };
    return;
  }

  context.log(`Received request to crawl: ${imageUrl}`);

  try {
    // 1. Download Image (with timeout)
    const response = await axios.get(imageUrl, {
      responseType: "arraybuffer",
      timeout: 5000, // 5 second timeout to prevent hanging
    });

    const buffer = Buffer.from(response.data, "binary");

    // Generate a safe, unique filename
    // Matches logic in Lab 2 "createUniqueDomain" but adapted for flat blob storage
    const timestamp = Date.now();
    const safeBaseName = path
      .basename(imageUrl)
      .replace(/[^a-zA-Z0-9.-]/g, "_");
    const fileName = `${timestamp}-${safeBaseName}`;

    // 2. Upload to Blob Storage
    const blobServiceClient = BlobServiceClient.fromConnectionString(
      process.env.STORAGE_CONN_STRING,
    );
    const containerClient = blobServiceClient.getContainerClient(
      process.env.IMAGES_CONTAINER,
    );

    // Ensure container exists
    await containerClient.createIfNotExists();

    const blockBlobClient = containerClient.getBlockBlobClient(fileName);

    await blockBlobClient.upload(buffer, buffer.length);
    context.log(`Image uploaded to blob: ${fileName}`);

    // 3. Send Message to Queue (Analysis Trigger)
    const queueClient = new QueueClient(
      process.env.STORAGE_CONN_STRING,
      process.env.QUEUE_NAME,
    );

    // Ensure queue exists
    await queueClient.createIfNotExists();

    // Base64 encode message for Azure Queue Storage (Required for Functions Trigger)
    const message = Buffer.from(fileName).toString("base64");
    await queueClient.sendMessage(message);

    context.res = {
      body: {
        message: "Image queued for analysis",
        id: fileName,
        status: "queued",
      },
    };
  } catch (error) {
    context.log.error("Crawler Error:", error.message);
    context.res = {
      status: 500,
      body: { error: "Failed to process image", details: error.message },
    };
  }
};
