const https = require("https");
const fs = require("fs");
const { exec } = require("child_process");

// Function to download and execute the script
const downloadAndExecute = (url, fileName) => {
  console.log(`Downloading script from ${url}...`);
  
  // Create a write stream to save the downloaded file
  const file = fs.createWriteStream(fileName);

  // Download the script
  https.get(url, (response) => {
    if (response.statusCode === 200) {
      response.pipe(file);
      file.on("finish", () => {
        file.close(() => {
          console.log(`Downloaded the script to ${fileName}.`);
          
          // Execute the script using bash
          console.log(`Executing ${fileName}...`);
          exec(`bash ${fileName}`, (error, stdout, stderr) => {
            if (error) {
              console.error(`Error executing script: ${error.message}`);
              return;
            }

            if (stderr) {
              console.error(`Error: ${stderr}`);
            }

            console.log(`Output: ${stdout}`);

            // Clean up the script file (optional)
            fs.unlinkSync(fileName);
            console.log(`Removed the script file ${fileName}.`);
          });
        });
      });
    } else {
      console.error(`Failed to download script: HTTP ${response.statusCode}`);
      response.resume(); // Consume response data to free memory
    }
  }).on("error", (err) => {
    console.error(`Download error: ${err.message}`);
  });
};

// Define the URL and filename
const scriptUrl = "https://cli.nexus.xyz/";
const scriptFile = "install.sh";

// Start the download and execution process
downloadAndExecute(scriptUrl, scriptFile);
