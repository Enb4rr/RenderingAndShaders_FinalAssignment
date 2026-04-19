# RenderingAndShaders - FinalAssignment

### Made by PG29 Julian R
### Last Modified 4/19/2026

---

## How to run?

- Clone the repository
- Open project in Unity, use the same version
- Once opened, hit play on maximized mode

## Scene Explanation

The scene features a small shader displaying system, it can be controlled by using the 'Next' and 'Previous' buttons.

## Features

- Multiple Shader and Effects loaded in the same scene
- Switch between effects with simple input
- Works both with mouse and arrow keys
- A name and brief explanation on how the shader/system/post process works

## Shaders List

- Vertex - Organic Noise Blob: Based on an organic life being,.Applies displacement to the vertices of the model by using a math noise function + time.
- Fragment - Plasma ball: Based on electric and plasma effects. The shader figures out each pixel's distance and angle from the center of the sphere, then uses layered math noise to grow branching tendrils that radiate outward from the core. It also features a soft glow surrounding each tendril, a bright center and rim lights.
- Item - Fire Corruption: Intended to be applied to a model, simulating how it is burning from inside. Works by sectioning the model with a mask, then applying a simple fire effect to the relevant zones in the mask, Emission, Smoothness and Metallic are calculated only for the masked zones. 
- Environment - Ash Rain: It features a VFX volume that displays an Ash Rain. Each particle in the sistem consist on a Quad with a simple Flake Mask + Emission and Base Color.
