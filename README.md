# homevision-project
Fun little side project incorporating computer vision and distributed architecture patterns.

## Image Processing

- When a photo is uploaded, determine if the photo is of a house
- If it does, store the image in a Houses/ folder within the bucket

## Address File Processing

- When a text file containing addresses (one address per line) is uploaded, parse the addresses
- Split the addresses into two separate files based on location:
    1. US addresses → store in one file
    2. Non-US addresses → store in another file