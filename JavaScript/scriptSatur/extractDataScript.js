const xlsx = require("xlsx");
const fs = require("fs");
const util = require("util");
const newman = require("newman");
const { Collection, Newman } = require("postman-collection");

const outputFilePath = "/Users/marina/satur-postman-xls/output.json";
const collectionsFolderPath = "/Users/marina/satur-postman-xls/collections/";
const excelFilePath = "/Users/marina/satur-postman-xls/output.xlsx";

async function runScript() {
  // Read the Excel file
  const wb = xlsx.readFile("./input.xlsx", { dateNF: "dd/mm/yyyy" });
  const ws = wb.Sheets["Sheet1"];
  const jsonData = xlsx.utils.sheet_to_json(ws, { raw: false });

  fs.mkdirSync(collectionsFolderPath, { recursive: true });

  // Function to format the date as dd.mm.yyyy
  function formatDate(dateString) {
    const [day, month, year] = dateString.split("/");
    return `${day.padStart(2, "0")}.${month.padStart(2, "0")}.${year}`;
  }

  // Iterate over the data and format the dates
  const modifiedData = jsonData.map((item) => {
    const modifiedItem = {
      ...item,
      nl_hotel_id: item.nl_hotel_id.replace(",", ""), // Remove comma from nl_hotel_id
      d_start_from: formatDate(item.d_start_from),
      d_end_to: formatDate(item.d_end_to),
    };
    return modifiedItem;
  });

  fs.writeFileSync("modified_data.json", JSON.stringify(modifiedData, null, 2));

  const newDataContent = fs.readFileSync("modified_data.json");
  const collectionContent = fs.readFileSync("postman_collection.json");

  const parsedNewData = JSON.parse(newDataContent);
  const parsedCollection = JSON.parse(collectionContent);

  // Loop through the modified data and create copies of the collection
  const extractedDataArray = []; // Array to store extracted data from each iteration

  for (let i = 0; i < parsedNewData.length; i++) {
    const { nl_hotel_id, d_start_from, d_end_to } = parsedNewData[i];

    // Create a copy of the original collection
    const newCollection = JSON.parse(JSON.stringify(parsedCollection));

    // Modify the new collection with the new data
    newCollection.item[0].request.body.raw =
      newCollection.item[0].request.body.raw.replace(
        /"nl_hotel_id":\s*\n/,
        `"nl_hotel_id": ${nl_hotel_id}\n`
      );
    newCollection.item[0].request.body.raw =
      newCollection.item[0].request.body.raw.replace(
        /"d_start_from":\s*".*?"/,
        `"d_start_from": "${d_start_from}"`
      );
    newCollection.item[0].request.body.raw =
      newCollection.item[0].request.body.raw.replace(
        /"d_end_to":\s*".*?"/,
        `"d_end_to": "${d_end_to}"`
      );

    // Write the modified collection to a new JSON file
    const newCollectionFileName = `new_postman_collection_${nl_hotel_id}_${i}.json`;
    const newCollectionFilePath = `${collectionsFolderPath}${newCollectionFileName}`;
    fs.writeFileSync(
      newCollectionFilePath,
      JSON.stringify(newCollection, null, 2)
    );

    // Run the Postman collection and extract the data
    const collectionResult = await runPostmanCollection(newCollectionFilePath);
    const summary = collectionResult;

    console.log(
      `Postman collection run complete for ${newCollectionFileName}.`
    );

    const responseData = summary.run.executions[0].response.json();

    const extractedData = responseData.data.map((item) => ({
      priceGroup: item.priceGroup,
      pricePerPerson: item.pricePerPerson,
      daysCount: item.daysCount,
      roomType: item.roomType,
      meal: item.meal,
    }));

    extractedDataArray.push(extractedData);
  }

  // Write the extracted data to the output JSON file
  fs.writeFileSync(outputFilePath, JSON.stringify(extractedDataArray, null, 2));
  console.log(`Data saved to ${outputFilePath}.`);

  fs.rmSync(collectionsFolderPath, { recursive: true });
}

// Function to run the Postman collection
function runPostmanCollection(collectionPath) {
  return new Promise((resolve, reject) => {
    const collection = new Collection(require(collectionPath));

    const newmanOptions = {
      collection,
      reporters: "cli",
      iterationCount: 1,
      bail: true,
    };

    newman.run(newmanOptions, (err, summary) => {
      if (err) {
        reject(err);
      } else {
        resolve(summary);
      }
    });
  });
}

// Main function to run the automation script
async function automate() {
  try {
    await runScript();
    console.log("Automation completed successfully.");
  } catch (error) {
    console.error("An error occurred during automation:", error);
  }
}

async function convertToExcel() {
  // Read the JSON data
  const jsonData = fs.readFileSync(outputFilePath, "utf8");
  const extractedDataArray = JSON.parse(jsonData);

  // Create a new workbook
  const wb = xlsx.utils.book_new();

  // Combine all extracted data into a single array
  const combinedData = extractedDataArray.flatMap((extractedData) =>
    extractedData.map((item) => [
      item.priceGroup,
      item.pricePerPerson,
      item.daysCount,
      item.roomType,
      item.meal,
    ])
  );

  // Create a worksheet and add the combined data with column names
  const worksheetName = "Sheet1"; // Name of the sheet
  const columnNames = [
    "priceGroup",
    "pricePerPerson",
    "daysCount",
    "roomType",
    "meal",
  ];
  const worksheetData = [columnNames, ...combinedData];
  const worksheet = xlsx.utils.aoa_to_sheet(worksheetData);
  xlsx.utils.book_append_sheet(wb, worksheet, worksheetName);

  // Save the workbook as an Excel file
  xlsx.writeFile(wb, excelFilePath);

  console.log(`Excel file saved to ${excelFilePath}.`);
}

async function runConversion() {
  try {
    await convertToExcel();
    console.log("Conversion completed successfully.");
  } catch (error) {
    console.error("An error occurred during conversion:", error);
  }
}

async function automate() {
  try {
    // Create the collections folder
    fs.mkdirSync(collectionsFolderPath, { recursive: true });

    await runScript();
    console.log("Automation completed successfully.");

    await runConversion();

  } catch (error) {
    console.error("An error occurred during automation:", error);
  }
}

automate();

// const xlsx = require("xlsx");
// const fs = require("fs");
// const util = require("util");
// const newman = require("newman");
// const { Collection, Newman } = require("postman-collection");

// const outputFilePath = "/Users/marina/satur-postman-xls/output.json";
// const collectionsFolderPath = "/Users/marina/satur-postman-xls/collections/";
// const excelFilePath = "/Users/marina/satur-postman-xls/output.xlsx";

// async function runScript() {
//   // Read the Excel file
//   const wb = xlsx.readFile("./input.xlsx", { dateNF: "dd/mm/yyyy" });
//   const ws = wb.Sheets["Sheet1"];
//   const jsonData = xlsx.utils.sheet_to_json(ws, { raw: false });

//    fs.mkdirSync(collectionsFolderPath, { recursive: true });

//   // Function to format the date as dd.mm.yyyy
//   function formatDate(dateString) {
//     const [day, month, year] = dateString.split("/");
//     return `${day.padStart(2, "0")}.${month.padStart(2, "0")}.${year}`;
//   }

//   // Iterate over the data and format the dates
//   const modifiedData = jsonData.map((item) => {
//     const modifiedItem = {
//       ...item,
//       nl_hotel_id: item.nl_hotel_id.replace(",", ""), // Remove comma from nl_hotel_id
//       d_start_from: formatDate(item.d_start_from),
//       d_end_to: formatDate(item.d_end_to),
//     };
//     return modifiedItem;
//   });

//   fs.writeFileSync("modified_data.json", JSON.stringify(modifiedData, null, 2));

//   const newDataContent = fs.readFileSync("modified_data.json");
//   const collectionContent = fs.readFileSync("postman_collection.json");

//   const parsedNewData = JSON.parse(newDataContent);
//   const parsedCollection = JSON.parse(collectionContent);

//   // Loop through the modified data and create copies of the collection
//   const extractedDataArray = []; // Array to store extracted data from each iteration

//   for (let i = 0; i < parsedNewData.length; i++) {
//     const { nl_hotel_id, d_start_from, d_end_to } = parsedNewData[i];

//     // Create a copy of the original collection
//     const newCollection = JSON.parse(JSON.stringify(parsedCollection));

//     // Modify the new collection with the new data
//     newCollection.item[0].request.body.raw =
//       newCollection.item[0].request.body.raw.replace(
//         /"nl_hotel_id":\s*\n/,
//         `"nl_hotel_id": ${nl_hotel_id}\n`
//       );
//     newCollection.item[0].request.body.raw =
//       newCollection.item[0].request.body.raw.replace(
//         /"d_start_from":\s*".*?"/,
//         `"d_start_from": "${d_start_from}"`
//       );
//     newCollection.item[0].request.body.raw =
//       newCollection.item[0].request.body.raw.replace(
//         /"d_end_to":\s*".*?"/,
//         `"d_end_to": "${d_end_to}"`
//       );

//     // Write the modified collection to a new JSON file
//     const newCollectionFileName = `new_postman_collection_${nl_hotel_id}_${i}.json`;
//     const newCollectionFilePath = `${collectionsFolderPath}${newCollectionFileName}`;
//     fs.writeFileSync(
//       newCollectionFilePath,
//       JSON.stringify(newCollection, null, 2)
//     );

//     // Run the Postman collection and extract the data
//     const collectionResult = await runPostmanCollection(newCollectionFilePath);
//     const summary = collectionResult;

//     console.log(
//       `Postman collection run complete for ${newCollectionFileName}.`
//     );

//     const responseData = summary.run.executions[0].response.json();

//     const extractedData = responseData.data.map((item) => ({
//       priceGroup: item.priceGroup,
//       pricePerPerson: item.pricePerPerson,
//       daysCount: item.daysCount,
//       roomType: item.roomType,
//       meal: item.meal,
//     }));

//     extractedDataArray.push(extractedData);
//   }

//   // Write the extracted data to the output JSON file
//   fs.writeFileSync(outputFilePath, JSON.stringify(extractedDataArray, null, 2));
//   console.log(`Data saved to ${outputFilePath}.`);

//   fs.rmdirSync(collectionsFolderPath, { recursive: true });
// }

// // Function to run the Postman collection
// function runPostmanCollection(collectionPath) {
//   return new Promise((resolve, reject) => {
//     const collection = new Collection(require(collectionPath));

//     const newmanOptions = {
//       collection,
//       reporters: "cli",
//       iterationCount: 1,
//       bail: true,
//     };

//     newman.run(newmanOptions, (err, summary) => {
//       if (err) {
//         reject(err);
//       } else {
//         resolve(summary);
//       }
//     });
//   });
// }

// // Main function to run the automation script
// async function automate() {
//   try {
//     await runScript();
//     console.log("Automation completed successfully.");
//   } catch (error) {
//     console.error("An error occurred during automation:", error);
//   }
// }
// async function convertToExcel() {
//   // Read the JSON data
//   const jsonData = fs.readFileSync(outputFilePath, "utf8");
//   const extractedDataArray = JSON.parse(jsonData);

//   // Create a new workbook
//   const wb = xlsx.utils.book_new();

//   // Combine all extracted data into a single array
//   const combinedData = extractedDataArray.flatMap((extractedData) =>
//     extractedData.map((item) => [
//       item.priceGroup,
//       item.pricePerPerson,
//       item.daysCount,
//       item.roomType,
//       item.meal,
//     ])
//   );

//   // Create a worksheet and add the combined data with column names
//   const worksheetName = "Sheet1"; // Name of the sheet
//   const columnNames = [
//     "priceGroup",
//     "pricePerPerson",
//     "daysCount",
//     "roomType",
//     "meal",
//   ];
//   const worksheetData = [columnNames, ...combinedData];
//   const worksheet = xlsx.utils.aoa_to_sheet(worksheetData);
//   xlsx.utils.book_append_sheet(wb, worksheet, worksheetName);

//   // Save the workbook as an Excel file
//   xlsx.writeFile(wb, excelFilePath);

//   console.log(`Excel file saved to ${excelFilePath}.`);
// }

// // // Main function to run the conversion
// async function runConversion() {
//   try {
//     await convertToExcel();
//     console.log("Conversion completed successfully.");
//   } catch (error) {
//     console.error("An error occurred during conversion:", error);
//   }
// }

// async function automate() {
//   try {
//     // Create the collections folder
//     fs.mkdirSync(collectionsFolderPath, { recursive: true });

//     await runScript();
//     console.log("Automation completed successfully.");

//     runConversion();

//     // Delete the collections folder
//     fs.rmdirSync(collectionsFolderPath, { recursive: true });
//   } catch (error) {
//     console.error("An error occurred during automation:", error);
//   }
// }

// automate();
