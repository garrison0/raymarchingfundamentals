---
sidebar_position: 1
---

import WebGL from '@site/src/components/WebGL';

# Make it twist

<WebGL />

The twist effect looks visually complicated, but it only requires a few lines of code. Here's our new `map` function that produces the twist effect in the example above: 

```cpp
vec2 map (vec3 p, float time) 
{ 
    vec2 res = vec2(1e10, 0.0);

    p = p + vec3(0.0, 0.0, 15.0);

    // twist
    float k = uSlider / 40.0; 
    float c = cos(k*p.y);
    float s = sin(k*p.y);
    mat2  m = mat2(c,-s,s,c);
    vec3 twisted = vec3(m*p.xz,p.y);

    res = vec2(sdRoundBox(twisted, vec3(0.5), 0.0), 15.0);

    return res;
}
```

`k` corresponds to the amount of the twist you want to add. In this example, the input slider value determines `k`. 

:::tip
Try varying `k` over time! For example, set `k = sin(time)`.
:::

Here's the key intuition: you don't need to derive a new distance function for the twisted shape. Instead, modify space by rotating the position vector, `p`, around the y axis, varying the degree of rotation by the magnitude of `y`. Then pass the rotated vector into the distance function for the "un-twisted" shape, which in this case is the box from the [starter example](/a-quick-background).

:::tip

In the `map` function, we build a [rotation matrix](https://en.wikipedia.org/wiki/Rotation_matrix) and use it to rotate `p` around the y axis. Try modifying the code to rotate around the x axis instead!
:::
