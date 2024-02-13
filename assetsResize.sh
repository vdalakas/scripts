#!/bin/bash
# assetsResize.sh
# Written on M2 Pro. Requires jq. Install with: brew install jq
# Vassilis Dalakas 2024

# Check if the required argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <original_image>"
    exit 1
fi

# Original image provided as input argument
original_image="$1"

# Check if the original image exists
if [ ! -f "$original_image" ]; then
    echo "Error: Original image '$original_image' not found."
    exit 1
fi

# Get the directory containing the original image
folder_path=$(dirname "$original_image")
# Extract filename from the original image path
filename_with_ext=$(basename "$original_image")
# Extract filename without extension
filename=${filename_with_ext%.*}

# Check if Contents.json exists in the same directory
contents_json="$folder_path/Contents.json"
if [ ! -f "$contents_json" ]; then
    echo "Error: Contents.json not found in the same directory as the original image."
    exit 1
fi

# Create a backup of the original JSON file
cp "$contents_json" "$folder_path/Contents.json.original"

# Extract icon sizes and scales from Contents.json
icon_data=$(jq -c '.images[]' "$contents_json")

# Extract fields after the "images" array
after_images=$(jq -c '. | del(.images)' "$contents_json")

# Loop through each icon size data and update the "images" array
updated_images=()
while IFS= read -r size_data; do
    # Extract size, scale
    size=$(jq -r '.size' <<< "$size_data")
    scale=$(jq -r '.scale // "1x"' <<< "$size_data")

    # Calculate resized dimensions
    width=$(echo "$size" | cut -dx -f1)
    height=$(echo "$size" | cut -dx -f2)
    scale_numeral=$(echo "$scale" | sed 's/x//')
    resized_width=$((width * scale_numeral))
    resized_height=$((height * scale_numeral))
    resized_basename="${filename}_${resized_width}x${resized_height}.png"

    # Resize the image
    resized_image="${folder_path}/${resized_basename}"
    sips -z "$resized_height" "$resized_width" "$original_image" --out "$resized_image"

    echo "Resized image created: $resized_image"

    # Update the JSON data with the resized image filename
    updated_data=$(jq --arg resized_basename "$resized_basename" '. + { "filename": $resized_basename }' <<< "$size_data")
    
    # Append updated data to the array
    updated_images+=( "$updated_data," )
done <<< "$icon_data"

# Remove the last comma from the last element in the array
last_index=$(( ${#updated_images[@]} - 1 ))
updated_images[$last_index]=${updated_images[$last_index]%','}

# Remove the curly braces from $after_images
after_images="${after_images#"{"}"
after_images="${after_images%"}"}"

# Construct the final JSON object with updated "images" array and fields after "images"
updated_json="{ \"images\": [${updated_images[*]}], $after_images }"

# Remove the curly braces from $after_images
updated_json="${updated_json%}"

# Write the updated JSON object back to Contents.json
echo "$updated_json" > "$contents_json.tmp" && mv "$contents_json.tmp" "$contents_json"

echo "New JSON file created."

