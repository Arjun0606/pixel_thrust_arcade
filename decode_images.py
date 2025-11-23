import json
import base64
import sys

def decode_image(json_path, output_path):
    try:
        with open(json_path, 'r') as f:
            data = json.load(f)
            
        if 'image' in data and 'base64' in data['image']:
            b64_string = data['image']['base64']
            img_data = base64.b64decode(b64_string)
            
            with open(output_path, 'wb') as out:
                out.write(img_data)
            print(f"Successfully saved {output_path}")
        else:
            print(f"No base64 image found in {json_path}")
            
    except Exception as e:
        print(f"Error processing {json_path}: {e}")

if __name__ == "__main__":
    decode_image('egg.json', 'egg.png')
    decode_image('baby.json', 'baby.png')
    decode_image('child.json', 'child.png')
    decode_image('teen.json', 'teen.png')
    decode_image('adult.json', 'adult.png')
    decode_image('elder.json', 'elder.png')
