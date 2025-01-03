#This script takes an image and blurs the left side of it. 
#This is useful for creating a background image for the Hyprlock lock screen. 
#The blurred left side will be used to display the lock screen UI, while the right 
#side will be used to display the wallpaper.
import sys
from PIL import Image, ImageFilter, ImageDraw

def blur_left_side(src, out, blur_width_percent):
  image = Image.open(src)
  width, height = image.size
  blur_width = int(width * blur_width_percent / 100)
  
  # Split the image into two parts
  left_side = image.crop((0, 0, blur_width, height))
  
  # Blur the left side
  blurred_left_side = left_side.filter(ImageFilter.GaussianBlur(radius=100))
  
  # Create a semi-transparent overlay
  overlay = Image.new('RGBA', blurred_left_side.size, (0, 0, 0, 64))  # Black with 50% opacity
  blurred_left_side = Image.alpha_composite(blurred_left_side.convert('RGBA'), overlay)
  
  # Paste the blurred left side back into the original image
  image.paste(blurred_left_side.convert('RGB'), (0, 0))
  image.save(out)

def main():
  if len(sys.argv) != 4:
    print("Usage: python3 hyprlock-prepare-background.py input_image output_image blur_width_percent")
    sys.exit(1)
  src = sys.argv[1]
  out = sys.argv[2]
  blur_width_percent = int(sys.argv[3])
  blur_left_side(src, out, blur_width_percent)

if __name__ == "__main__":
  main()