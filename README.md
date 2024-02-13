# scripts
Mac os cli scripts for various tasks

# assetsResize.sh

This Bash script, `assetsResize.sh`, is designed to resize images and update a `Contents.json` file used in iOS development projects. It requires the `jq` tool to be installed (which can be done via Homebrew with `brew install jq`).

## Overview

The script takes an original image file as input and checks if it exists. It also verifies the presence of a `Contents.json` file in the same directory. The `Contents.json` file typically contains metadata about assets used in an iOS app, such as icon sizes and scales.

The script extracts icon sizes and scales from the `Contents.json` file and loops through each size data to resize the original image accordingly. It calculates the resized dimensions based on the provided sizes and scales and uses the sips command to perform the resizing operation.

After resizing each image, the script updates the JSON data with the resized image filename and constructs a new JSON object. Finally, it writes the updated JSON object back to the `Contents.json` file, effectively updating the metadata for the resized images.

The script is useful for developers working on iOS projects who need to resize and update image assets efficiently within the project's asset catalog.

## Usage

To use the script, provide the original image file as an argument:

```bash
./assetsResize.sh <path_to_assets_catalog/original_image>


