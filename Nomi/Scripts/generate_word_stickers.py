#!/usr/bin/env python3
"""
Generate kawaii word stickers for the Nomi app using DALL-E 3.
"""

import os
import json
import time
import base64
import urllib.request
import urllib.error
from pathlib import Path

# Configuration
OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY", "")
ASSETS_PATH = Path(__file__).parent.parent / "Nomi" / "Assets.xcassets" / "WordStickers"

# All unique word sticker assets needed
WORDS = [
    # Cafe
    ("word_coffee", "coffee", "a cute steaming cup of coffee"),
    ("word_tea", "tea", "a cute teacup with steam"),
    ("word_cake", "cake", "a cute slice of strawberry cake"),
    ("word_sugar", "sugar", "a cute sugar bowl with a spoon"),
    ("word_milk", "milk", "a cute milk bottle or carton"),
    ("word_menu", "menu", "a cute menu card"),
    ("word_seat", "seat", "a cute cafe chair"),
    ("word_cup", "cup", "a cute drinking cup"),
    
    # Restaurant
    ("word_rice", "rice", "a cute bowl of rice"),
    ("word_water", "water", "a cute glass of water"),
    ("word_chopsticks", "chopsticks", "cute chopsticks"),
    ("word_delicious", "delicious", "a cute happy face tasting something yummy"),
    ("word_bill", "bill", "a cute receipt or bill"),
    ("word_reservation", "reservation", "a cute calendar or booking note"),
    ("word_recommend", "recommendation", "a cute thumbs up or star"),
    ("word_fish", "fish", "a cute fish on a plate"),
    
    # Store
    ("word_howmuch", "how much", "a cute price tag with question mark"),
    ("word_buy", "buy", "a cute shopping basket"),
    ("word_expensive", "expensive", "cute gold coins or diamond"),
    ("word_cheap", "cheap", "a cute coin with happy face"),
    ("word_bag", "bag", "a cute shopping bag"),
    ("word_cash", "cash", "cute paper money or bills"),
    ("word_card", "card", "a cute credit card"),
    ("word_receipt", "receipt", "a cute receipt paper"),
    
    # Station
    ("word_train", "train", "a cute train"),
    ("word_ticket", "ticket", "a cute train ticket"),
    ("word_exit", "exit", "a cute exit door sign"),
    ("word_entrance", "entrance", "a cute entrance door"),
    ("word_platform", "platform", "a cute train platform"),
    ("word_next", "next", "a cute arrow pointing forward"),
    ("word_ride", "ride", "a cute person riding"),
    ("word_getoff", "get off", "a cute person stepping off"),
    
    # Home
    ("word_room", "room", "a cute cozy room"),
    ("word_bed", "bed", "a cute comfy bed"),
    ("word_window", "window", "a cute window with curtains"),
    ("word_door", "door", "a cute wooden door"),
    ("word_tv", "TV", "a cute television"),
    ("word_fridge", "refrigerator", "a cute refrigerator"),
    ("word_bath", "bath", "a cute bathtub with bubbles"),
    ("word_kitchen", "kitchen", "a cute kitchen scene"),
    
    # Park
    ("word_tree", "tree", "a cute green tree"),
    ("word_flower", "flower", "a cute colorful flower"),
    ("word_sky", "sky", "cute clouds in blue sky"),
    ("word_bird", "bird", "a cute singing bird"),
    ("word_walk", "walk", "cute footprints or walking person"),
    ("word_weather", "weather", "a cute sun with face"),
    ("word_bench", "bench", "a cute park bench"),
    ("word_dog", "dog", "a cute fluffy dog"),
    
    # Hospital
    ("word_doctor", "doctor", "a cute doctor with stethoscope"),
    ("word_medicine", "medicine", "cute medicine pills or bottle"),
    ("word_pain", "pain", "a cute bandage or sad face"),
    ("word_fever", "fever", "a cute thermometer"),
    ("word_hospital", "hospital", "a cute hospital building"),
    ("word_cold", "cold", "a cute person sneezing"),
    ("word_healthy", "healthy", "a cute heart with sparkles"),
    ("word_rest", "rest", "a cute sleeping face or pillow"),
    
    # Office
    ("word_work", "work", "a cute briefcase"),
    ("word_meeting", "meeting", "cute people in meeting"),
    ("word_phone", "phone", "a cute smartphone"),
    ("word_email", "email", "a cute envelope with @ sign"),
    ("word_computer", "computer", "a cute laptop computer"),
    ("word_boss", "boss", "a cute person in suit"),
    ("word_colleague", "colleague", "cute friends working together"),
    ("word_document", "document", "cute paper documents"),
]


def generate_sticker(asset_name: str, english_word: str, description: str) -> bool:
    """Generate a single kawaii sticker using DALL-E 3."""
    
    asset_dir = ASSETS_PATH / f"{asset_name}.imageset"
    asset_dir.mkdir(parents=True, exist_ok=True)
    
    # Check if image already exists
    image_path = asset_dir / f"{asset_name}.png"
    if image_path.exists():
        print(f"✓ {asset_name} already exists, skipping...")
        return True
    
    prompt = f"""Create a kawaii Japanese-style sticker of {description}. 
    Style: Cute, chibi, pastel colors, simple design, soft rounded shapes, minimal details.
    The sticker should look like a Japanese emoji or LINE sticker.
    White or transparent background.
    Adorable, friendly expression if applicable.
    No text or words in the image."""
    
    try:
        data = json.dumps({
            "model": "dall-e-3",
            "prompt": prompt,
            "n": 1,
            "size": "1024x1024",
            "quality": "standard",
            "response_format": "b64_json"
        }).encode("utf-8")
        
        request = urllib.request.Request(
            "https://api.openai.com/v1/images/generations",
            data=data,
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Bearer {OPENAI_API_KEY}"
            }
        )
        
        with urllib.request.urlopen(request, timeout=120) as response:
            result = json.loads(response.read().decode("utf-8"))
        
        if "data" in result and len(result["data"]) > 0:
            image_b64 = result["data"][0]["b64_json"]
            image_data = base64.b64decode(image_b64)
            
            # Save the image
            with open(image_path, "wb") as f:
                f.write(image_data)
            
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
            
            contents_path = asset_dir / "Contents.json"
            with open(contents_path, "w") as f:
                json.dump(contents, f, indent=2)
            
            print(f"✓ Generated {asset_name}")
            return True
    
    except urllib.error.HTTPError as e:
        error_body = e.read().decode("utf-8") if e.fp else ""
        print(f"✗ HTTP Error for {asset_name}: {e.code} - {error_body}")
        return False
    except Exception as e:
        print(f"✗ Error generating {asset_name}: {e}")
        return False


def main():
    if not OPENAI_API_KEY:
        print("Error: OPENAI_API_KEY environment variable not set")
        print("Run: export OPENAI_API_KEY=your_key_here")
        return
    
    print(f"Generating {len(WORDS)} word stickers...")
    print(f"Output: {ASSETS_PATH}")
    print("=" * 50)
    
    success_count = 0
    for i, (asset_name, english_word, description) in enumerate(WORDS):
        print(f"\n[{i+1}/{len(WORDS)}] {asset_name} ({english_word})")
        
        if generate_sticker(asset_name, english_word, description):
            success_count += 1
        
        # Rate limiting - DALL-E has strict rate limits
        if i < len(WORDS) - 1:
            time.sleep(2)  # 2 second delay between requests
    
    print("=" * 50)
    print(f"Complete! Generated {success_count}/{len(WORDS)} stickers.")


if __name__ == "__main__":
    main()
