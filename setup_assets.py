import os
import shutil
import json

def create_imageset(image_path, asset_name, assets_dir):
    if not os.path.exists(image_path):
        print(f"Skipping {asset_name} - image not found")
        return
        
    imageset_dir = os.path.join(assets_dir, f"{asset_name}.imageset")
    os.makedirs(imageset_dir, exist_ok=True)
    
    # Move/Copy image
    dest_image_path = os.path.join(imageset_dir, f"{asset_name}.png")
    shutil.copy(image_path, dest_image_path)
    
    # Create Contents.json
    contents = {
        "images": [
            {
                "filename": f"{asset_name}.png",
                "idiom": "universal",
                "scale": "1x"
            },
            {
                "idiom": "universal",
                "scale": "2x"
            },
            {
                "idiom": "universal",
                "scale": "3x"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    
    with open(os.path.join(imageset_dir, "Contents.json"), 'w') as f:
        json.dump(contents, f, indent=2)
    
    print(f"Created {imageset_dir}")

if __name__ == "__main__":
    assets_path = "/Users/arjun/pixelwhis/pixelwhis/Assets.xcassets"
    
    for stage in ['egg', 'baby', 'child', 'teen', 'adult', 'elder']:
        if os.path.exists(f"{stage}.png"):
            create_imageset(f"{stage}.png", stage, assets_path)
