---
sidebar_position: 2
---

# Getting Started

## Before you begin

1. [Check if you can run WebGL2.](https://get.webgl.org/webgl2/)  
  Your browser must be compatible with WebGL2 in order to continue.
2. Clone [this starter template](https://github.com/garrison0/raymarching-techniques).  
  ```bash
  git clone https://github.com/garrison0/raymarching-techniques.git
  ```
3. Run the starter template.  
  ```bash
  cd raymarching-techniques
  cd starter
  npm install
  python -m SimpleHTTPServer
  ```
  This step uses Python to host an HTTP server that serves your project's HTML. If you don't have Python, [install it](https://www.python.org/downloads/). If you know of another way to host an HTTP server in the command line, feel free to use it.  
  You can now view the raymarching demo at `http://localhost:3000/`.
4. Visit `http://localhost:3000/` in your browser.

You should see this:

![Starter program](/img/raymarching/starter.png)

We're rendering a box! Not very exciting, but there's a lot to unpack here.

The rest of this page will briefly explain what's going on in the starter program.

## The WebGL part

Since this tutorial is about raymarching, and *not* about WebGL, you don't need to know how WebGL works in order to proceed. In case you're still wondering how everything fits together, this section will give you a high level overview.

### index.html

The `index.html` being served by your Python server includes an [HTML canvas](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API). WebGL draws in the canvas.

![Starter canvas](/img/raymarching/starter-canvas.png)

This CSS code styles the canvas. We make the canvas as wide as the browser window it lives in and 500 pixels tall:

![Starter canvas styling](/img/raymarching/starter-styling.png)

Finally, we have a `<script>` tag that imports and runs the `index.js` file. `index.js` contains the JavaScript code used to initialize and run WebGL.

![Starter script tag](/img/raymarching/starter-script.png)

The rest of `index.html` is boilerplate code. We can ignore it for now.

### index.js

WebGL is a rendering engine, not a 3D graphics library. It does not hold your hand.

Imagine you're in an old airplane cockpit with hundreds of switches and levers. Before take-off, you need to go over a big checklist to make sure all the switches and levers are set the way you want them. If something's not set right, you might notice that the airplane isn't behaving the way you expect. Then you have to turn around, land, and go over your checklist all over again.

WebGL feels a bit like that, but instead of switches and levers, WebGL has program state. The various program state options tell WebGL exactly what to do with all the data you give it. WebGL then talks to your GPU in order to process the data and draw it in the way that you've specified.

3D graphics libraries, like Three.JS and Babylon, are built on top of WebGL. They *do* hold your hand. They hide these details from you. They also provide pre-defined materials, light sources, geometries, math helper functions, and so on. The take-away: use Three.JS or Babylon if you want to get anything done. Use WebGL only if you want low level control.

:::tip

Want to know more about WebGL? Check out [WebGL Fundamentals](https://webglfundamentals.org/)!

:::

The WebGL program in `index.js` draws a rectangle that fills the entire length and width of the canvas. The fragment shader determines what color each pixel in the rectangle should be. Since we can make this pixel whatever color we want, we can do the raymarching *within* the fragment shader, coloring the pixel according to a raymarched 3D scene. We'll discuss more about the fragment shader later.

:::note

For simplicity, we're using [Tiny WebGL library (TWGL)](https://twgljs.org/). TWGL spares us from lots of boilerplate WebGL code.

:::

The logic of `index.js` follows three steps:

1. #### Fetch the shader files  
  Because we're storing the shader code in separate files, we need to fetch these files from our local directory before WebGL can use our code. We use the [Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch) to do so.

  ```javascript title="index.js"
  // -------- FETCH FILES --------- //
  // keys correspond to the file names of each shader
  var shaders = {'fs': '', 'vs': ''};
  var count = 0;
  let numFiles = 2;

  for (const key of Object.keys(shaders)) { 
    fetch('./shader/' + key + '.glsl')
      .then(response => response.text())
      .then(text => {
        shaders[key] = text;
        count = count + 1;
        if (count >= numFiles) 
          init(shaders);
      });
  };
  ```

  Alternatively, you could write your shader code within `<script>` tags in `index.html`.
  After fetching the shader code, we use it to initialize WebGL.

2. #### Initialize WebGL

  ```javascript title="index.js"
  function init(shaders)
  {
    state.programInfo = twgl.createProgramInfo(gl, [shaders['vs'], shaders['fs']]);
    state.bufferInfo = twgl.primitives.createXYQuadBufferInfo(gl);
    requestAnimationFrame(render);
  }
  ```

  Initialization is only a few lines because of TWGL:
  
    1. Pass WebGL the shader code.
    
    ```javascript
    state.programInfo = twgl.createProgramInfo(gl, [shaders['vs'], shaders['fs']]);
    ```
    WebGL uses the combination of the vertex shader ('vs') and the fragment shader ('fs') to construct a [WebGL program](https://developer.mozilla.org/en-US/docs/Web/API/WebGLProgram). WebGL uses this program to draw.

    2. Call this TWGL helper function to get the data WebGL requires in order to draw a rectangle across the canvas.
    ```javascript
    state.bufferInfo = twgl.primitives.createXYQuadBufferInfo(gl);
    ```

    3. Enter the render loop.  
    ```javascript
    requestAnimationFrame(render);
    ```
    `requestAnimationFrame(render)` tells the browser to call the `render` function the next time it repaints the page. Since `render` itself includes a call to `requestAnimationFrame(render)`, the `render` function loops as long as the browser tab stays open.

3. #### Render

  ```javascript title="index.js"
  function render(time) { 
    time *= 0.001; // milliseconds to seconds

    twgl.resizeCanvasToDisplaySize(gl.canvas, 1.0);
    gl.viewport(0, 0, gl.canvas.clientWidth, gl.canvas.clientHeight);

    const uniforms = {
      uTime: time,
      uResolution: [gl.canvas.clientWidth, gl.canvas.clientHeight]
    }

    gl.useProgram(state.programInfo.program);
    twgl.setUniforms(state.programInfo, uniforms);
    twgl.setBuffersAndAttributes(gl, state.programInfo, state.bufferInfo);
    twgl.drawBufferInfo(gl, state.bufferInfo);

    requestAnimationFrame(render);
  }
  ```

  During each iteration of the loop, we:

    1. Resize the canvas, in case the browser window has resized.

    ```javascript
    twgl.resizeCanvasToDisplaySize(gl.canvas, 1.0);
    gl.viewport(0, 0, gl.canvas.clientWidth, gl.canvas.clientHeight);
    ```

    2. Set the uniforms.
    
    ```javascript
    const uniforms = {
      uTime: time,
      uResolution: [gl.canvas.clientWidth, gl.canvas.clientHeight]
    }
    ...
    twgl.setUniforms(state.programInfo, uniforms);
    ```

    Using [WebGL uniforms](https://webglfundamentals.org/webgl/lessons/webgl-shaders-and-glsl.html#uniforms), we pass data from JavaScript to our shader code. In particular, we're passing the time and the size of the canvas. 

    3. Tell WebGL to use the WebGL program containing our shader code and to use the data needed to draw a rectangle.

    ```javascript
    gl.useProgram(state.programInfo.program);
    ...
    twgl.setBuffersAndAttributes(gl, state.programInfo, state.bufferInfo);
    ```
    
    4. Draw the rectangle, which is the next frame of our raymarching animation.

    ```javascript
    twgl.drawBufferInfo(gl, state.bufferInfo);
    ```

## The Raymarching part

Our raymarching code lives in our fragment shader at `shader/fs.glsl`. The fragment shader determines what color to draw each pixel in the rectangle as.

Like a C program, the entry point of the fragment shader is the `main` function.

The fragment shader performs the following steps for **each pixel**:

1. Find the direction of the ray to be cast
2. March the ray in that direction until an intersection is found or until we reach the maximum number of iterations
3. Determine the color to render by using the intersection data to perform lighting calculations

Let's look at each step in more detail.

### Find the direction of the ray to be cast

```cpp title="fs.glsl"
in vec2 vUv;
...

mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
  vec3 cw = normalize(ta-ro);
  vec3 cp = vec3(sin(cr), cos(cr),0.0);
  vec3 cu = normalize( cross(cw,cp) );
  vec3 cv =          ( cross(cu,cw) );
  return mat3( cu, cv, cw );
}

void main() {
  // camera ray origin
  vec3 ro = vec3( 0.0, 3.5, 1.0);
  // camera target
  vec3 ta = vec3( 0.0, 3.5, 0.0);

  mat3 ca = setCamera(ro, ta, 0.0);
  float aspect = uResolution.x / uResolution.y;
  vec2 p = vec2(aspect, 1.0) * (vUv - vec2(0.5));

  // ray direction
  vec3 rd = ca * normalize( vec3(p, 5.0) );
}
```

Remember the ray tracing picture from the introduction?

![ray tracing grid img](https://developer.nvidia.com/sites/default/files/pictures/2018/RayTracing/ray-tracing-image-1.jpg)

Let's say the camera lives at the origin and the camera is "looking" in the direction of the z axis:

$$
\vec{ro} = \begin{bmatrix} 0 \\ 0 \\ 0 \end{bmatrix} \qquad
\vec{ta}=\begin{bmatrix} 0 \\ 0 \\ 1 \end{bmatrix}
$$

How we can generate our ray's direction from this information? In other words, what pixel in the image grid are we pointing at?

[](img of not knowing what ray direction/position in grid is!)

We can get to the center of the image grid by following along the direction the camera is "looking" at. Call this direction the $"Forward"$ vector:

[img of (1) -- get to the center](...)

What we really need are the $"Up"$ and $"Right"$ vectors of the image grid:

[](img of (2) -- up and right)

We also need some way of telling how far $"Right"$ and how far $"Up"$ we should go in the grid for each pixel. Then, just like locating a position $(x,y)$ within 2d Cartesian coordinates, we could locate our position within the image grid:

<figure style={{textAlign: 'center', fontStyle: 'italic'}}>
  <img src="/img/raymarching/cartesian-point.png" width="450" style={{marginLeft: 'auto', marginRight: 'auto'}}/>
  <figcaption> (x,y) = (2,1) = 2 * "Right + 1 * "Up"</figcaption>
</figure>

In this case, we're in luck. Since the camera is looking straight ahead, the camera is axis aligned. We can use the $z$ axis $\begin{bmatrix} 0 \\ 0 \\ 1 \end{bmatrix}$ as our $"Forward"$ vector, and we can use the other two axes, $x$ and $y$--

$$
"Right" = \begin{bmatrix} 1 \\ 0 \\ 0 \end{bmatrix} \qquad
"Up" = \begin{bmatrix} 0 \\ 1 \\ 0 \end{bmatrix}
$$

--to locate our ray on the image grid.

Remember how we're actually drawing a full screen rectangle? We can use this rectangle's texture coordinates `uv` to locate our position within the canvas. This, in turn, tells us how far "right" and how far "up" we need to go in the image grid!

Our ray direction is then:

$$
\vec{rd} = uv.x * "Right" + uv.y * "Up" + "Forward"  
$$

Each position in the image grid is determined by this equation. Since our camera is axis aligned, this simplifies to:

$$
\begin{aligned}
  \vec{rd} &= uv.x * \begin{bmatrix} 1 \\ 0 \\ 0 \end{bmatrix} + uv.y * \begin{bmatrix} 0 \\ 1 \\ 0 \end{bmatrix} + \begin{bmatrix} 0 \\ 0 \\ 1 \end{bmatrix} \\
  &= \begin{bmatrix} uv.x \\ uv.y \\ 1 \end{bmatrix}
\end{aligned}
$$

:::tip

Texture coordinates are interpolated values that tell us our relative position within a rendered geometry. They're normally used for adding textures, hence the name.

For more details on WebGL textures, check out the [WebGL fundamentals guide](https://webglfundamentals.org/webgl/lessons/webgl-3d-textures.html).

:::

What about in general? How can we generate a ray direction for each pixel given *any* $"Forward"$ vector?

The math is exactly the same, but we need some way of figuring out the $"Up"$ and $"Right"$ vectors. Here are the steps:

1. By the definition of the target vector, $"Forward"$ will always be $\vec{ta} - \vec{ro}$:

  [pic](...)

2. Choose the $y$ axis $\begin{bmatrix} 0 \\ 1 \\ 0 \end{bmatrix}$ as a temporary $"Up"$:

  [pic](...)

3. Use the cross product to find $"Right"$:

  $$
  "Right" = "Forward" \times "Up"
  $$

  [pic](...)

:::note

The cross product $\vec{c} = \vec{a} \times \vec{b}$ is defined to be perpendicular to both $\vec{a}$ and $\vec{b}$.

:::

4. Use the $"Right"$ vector to find the true $"Up"$ vector that is perpendicular to both $"Forward"$ and $"Right"$:

  $$
  "Up" = "Right" \times "Forward"
  $$

  [pic](...)

Now repeat the math with the UV coordinates!

$$
\vec{rd} = uv.x * "Right" + uv.y * "Up" + "Forward"  
$$

For simplicity, we can represent this operation using a matrix:

$$
\vec{rd} = \begin{bmatrix} "Right".x & "Up".x & "Forward".x \\ "Right".y & "Up".y & "Forward".y \\ "Right".z & "Up".z & "Forward".z \end{bmatrix} \begin{bmatrix} uv.x \\ uv.y \\ 1 \end{bmatrix}
$$

Expand the math and it looks exactly the same:

$$
\begin{aligned}
\vec{rd} &= "Right".x * uv.x + "Up".x * uv.y + "Forward".x \\
         &+ "Right".y * uv.x + "Up".y * uv.y + "Forward".y \\
         &+ "Right".z * uv.x + "Up".z * uv.y + "Forward".z \\
         &= uv.x * "Right" + uv.y * "Up" + "Forward" 
\end{aligned}
$$

#### Rotate the camera about the $"Forward"$ axis

```cpp
mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
  vec3 cw = normalize(ta-ro);
  vec3 cp = vec3(sin(cr), cos(cr),0.0);
  vec3 cu = normalize( cross(cw,cp) );
  vec3 cv =          ( cross(cu,cw) );
  return mat3( cu, cv, cw );
}
```

The `setCamera` function builds the matrix which contains the $"Right"$, $"Up"$, and $"Forward"$ vectors.

`cr` represents the camera rotation angle. Instead of choosing the $y$ axis as the temporary $"Up"$ vector, we choose `cp`, a rotated $"Up"$ vector, based on `cr`:

```cpp
vec3 cp = vec3(sin(cr), cos(cr),0.0);
```

Since the $"Right"$ vector is obtained by taking the cross product of $"Forward"$ and `cp`, the rotated $"Up"$ vector, we're essentially rotating the image grid around the $"Forward"$ vector.

:::tip

Set `cr` in `main` to `cos(uTime)` and view your program:

```cpp
mat3 ca = setCamera(ro, ta, cos(uTime));
```

<div style={{width: '100%', height: '0px', position: 'relative', 
        paddingBottom: '43.750%', marginBottom: '1rem'}}>
  <iframe src="https://streamable.com/e/fswox1" frameborder="0" width="100%" height="100%" allowfullscreen 
  style={{width: '100%', height: '100%', 
          position: 'absolute', left: '0px', 
          top: '0px', overflow: "hidden;"}}>
  </iframe>
</div>

Notice how the $"Up"$ and $"Right"$ vectors are rotating around the $"Forward$" vector, making it look like the box itself is rotating!

:::

#### Zoom in and out

```cpp
vec3 rd = ca * normalize( vec3(p, 5.0*abs(cos(uTime)) ) );
```

The `5.0` in `vec3(p, 5.0)` is like a zoom.

Recall the definition of `rd`:

$$
\vec{rd} = uv.x * "Right" + uv.y * "Up" + "Forward"  
$$

What would happen if we multipled $"Forward"$ by some constant $c > 1$, pushing the image grid further away from the camera?

(give picture of how far away from grid => how zoomed in it looks)

The visual field gets smaller. Since we're not moving the camera position, $\vec{ro}$, all we're doing is decreasing variation along the $"Up"$ and "$Right"$ directions across all of the rays. The effect: more rays being focused around the $"Forward"$ direction. Since each ray corresponds with a pixel on the screen, this looks like zooming in.

:::tip

Set $c =$ `5.0` to `5.0 * abs(cos(uTime))` and view your program:

```cpp
vec3 rd = ca * normalize( vec3(p, 5.0*abs(cos(uTime)) ) );
```

<div style={{width: '100%', height: '0px', position: 'relative', 
        paddingBottom: '43.750%', marginBottom: '1rem'}}>
  <iframe src="https://streamable.com/e/6rm0ug" frameborder="0" width="100%" height="100%" allowfullscreen 
  style={{width: '100%', height: '100%', 
          position: 'absolute', left: '0px', 
          top: '0px', overflow: "hidden;"}}>
  </iframe>
</div>

As $c$ gets closer to $0$, the image grid gets closer to the camera, zooming out. Likewise, when $c$ gets closer to $5$, the image grid gets farther from the camera, zooming in.

:::

### March the ray

```cpp title="fs.glsl"
vec2 raycast (in vec3 ro, in vec3 rd, float time)
{
  vec2 res = vec2(-1.0,-1.0);

  float tmin = 0.001;
  float tmax = 100.0;

  float eps = 0.0015;
  float t = tmin;
  for( int i = 0; i < 228 && t < tmax; i++) {
    vec2 h = map( ro + rd*t, time );

    if( abs(h.x) < eps){
      res = vec2(t, h.y);
      break;
    }

    t += h.x;
  }

  return res;
}
```

During each step of the loop, we:

  1. Find the minimum distance to any object in the scene
  ```cpp
  vec2 h = map( ro + rd*t, time );
  ```
  2. Exit the loop if the minimum distance is below a threshold (eps)
  ```cpp
  if( abs(h.x) < eps){
    res = vec2(t, h.y);
    break;
  }
  ```
  This signifies that an intersection has been detected.
  3. Else, step the ray by the minimum distance.
  Distance functions are blind to direction. Since our map function does not tell us the direction of any of the objects, we only know we can safely step by the minimum distance each iteration.
  [Minimum distance illustration](...)

#### Map

```cpp title="fs.glsl"
vec2 map (vec3 p, float time) 
{ 
  vec2 res = vec2(1e10, 0.0);
  p = p + vec3(0.0, -3.5, 15.0);
  res = vec2(sdRoundBox(p, vec3(0.5), 0.0), 15.0);
  return res;
}
```

`Map` simply chains together a bunch of SDFs, returning the minimum distance. In our case, `map` only contains the SDF for the box.

Notice how the result `res` is a vec2. For convenience, we stick the material ID of the nearest object in `res.y`. `raycast` then returns this material ID in case it detects an intersection. Finally, `render` uses this material ID to determine the pixel color.

#### Signed distance functions (SDFs)

```cpp title="fs.glsl"
float sdRoundBox( vec3 p, vec3 b, float r )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}
```

SDFs are functions that return the minimum distance to some primitive shape. More complicated shapes are created by combining these "primitives" together in a process called "modeling."

:::tip

Watch [this video](https://youtu.be/62-pRVZuS5c) to see how the SDF for a box is derived!

:::

### Determine the color

```cpp title="fs.glsl"
vec3 render(in vec3 ro, in vec3 rd, float time)
{
  vec3 col = vec3(0.95);

  vec2 res = raycast(ro,rd, time);
  float t = res.x;
  float m = res.y;

  vec3 pos = ro + rd*t;

  // lighting
  if ( m > 5.0 ) { 
    vec3 nor = calcNormal(pos, time);
    col = nor;
  }
  
  return vec3( clamp(col, 0.0, 1.0) );
}
```

Once an intersection is found, we return the material ID `m` of the object intersected with.

We use this material ID in the 'render' function. 'render' needs to know the material properties of the object (shininess, color, and so on) during lighting calculations in order to determine the color of the pixel.

For now, we're avoiding all of that and setting the color to the normal vector:

```cpp
vec3 nor = calcNormal(pos, time);
col = nor;
```

#### Find the normal

```cpp title="fs.glsl"
vec3 calcNormal( in vec3 p, float time )
{
  const float eps = 0.0001;
  const vec2 h = vec2(eps,0);
  return normalize( vec3(map(p+h.xyy, time).x - map(p-h.xyy, time).x,
                         map(p+h.yxy, time).x - map(p-h.yxy, time).x,
                         map(p+h.yyx, time).x - map(p-h.yyx, time).x ) );
}
```

`calcNormal` finds the normal direction by the method of central differences. Do you remember the formal definition of the derivative from Calculus?

$$
\lim\limits_{\epsilon{} \rarr 0}{ \frac{f(x + \epsilon{}) - f(x)}{\epsilon{}} }
$$

<div style={{textAlign: 'center', marginBottom: '1em'}}><i>Definition of the derivative</i></div>

You can approximate the derivative by taking small values of $\epsilon{}$.

It works in three dimensions, too. Conveniently, the derivative is defined to be in direction of the normal vector in vector calculus. Amazing.

In the code, we're using $map$ for $f$ and approximating the derivative along each direction. Given $\vec{h} = (\epsilon{}, 0)$, $h.xyy$ is GLSL shorthand for $(\epsilon{}, 0, 0)$. Likewise for the other directions:

```cpp
return normalize( vec3(map(p+h.xyy, time).x - map(p-h.xyy, time).x,
                       map(p+h.yxy, time).x - map(p-h.yxy, time).x,
                       map(p+h.yyx, time).x - map(p-h.yyx, time).x ) );
```

:::note

We don't need to divide by $\epsilon{}$ because we're normalizing the vector. Remember, we don't actually care about the magnitude of the derivative, we're just using it to find the direction of the normal vector.

:::

And we're done! But our demo is boring--we're only seeing one side of the box. We'll fix this in the next article.
