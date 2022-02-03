---
sidebar_position: 1
---

# Introduction

Have you ever visited [ShaderToy](https://www.shadertoy.com)? Most ShaderToy demos use a technique called ray marching. Ray marching is a graphical technique which, like its more well known sibling [ray tracing](https://en.wikipedia.org/wiki/Ray_tracing_(graphics)), renders an image by casting rays into a scene filled with objects.

## Who's this guide for?

Anyone interested in ray marching and the demoscene. You need some background in programming, vector math, and trigonometry to follow along. The more you know, the easier it'll be.

## What's this guide for?

This tutorial introduces you to some key ray marching techniques. With each technique, you'll add to a basic "Hello World" raymarching program. By the end of the process, you'll have recreated this animation:

<iframe src="https://streamable.com/e/m1u4ch?nocontrols=1" width="560" height="315" frameborder="0" allowfullscreen></iframe>

## Ray tracing

Imagine shooting a ray out from your eyes towards each pixel on your computer screen. Your mind "renders" this pixel as a color. Now imagine that your computer screen is transparent. Each ray continues through your screen until it intersects with whatever object lies behind the screen. The color your mind "renders" this new "pixel" as is going to depend on:

- The position of intersection: is the object in fog, or in a shadow?
- The object's material: is the object metallic and shiny, or soft and diffuse?
- The kind of light source in the scene: is the light an overhead light, or more like a flashlight?
- The angle between the object's surface and the viewer: is the ray grazing the surface, or hitting the surface head-on?

And so on.

In reality, rays of light travel from light sources, to objects, until finally hitting your eye's retina. But ray tracing works in this backwards way--by shooting rays into a scene through an imaginary grid in front of an imaginary "camera."

![ray tracing grid img](https://developer.nvidia.com/sites/default/files/pictures/2018/RayTracing/ray-tracing-image-1.jpg)

Ray tracing requires that objects in the scene have well defined geometries, like triangle meshes, which have closed solution ray intersection tests. Using these tests, you can determine the nearest position of intersection for each ray.

Ray marching iteratively steps each ray into the scene until it detects an intersection. All you need to do ray marching is a function which returns the distance to each object in the scene. When the distance is negative, or close to zero, you know when to stop.

<img width="100%" src="https://wallisc.github.io/assets/Moana/Diagram2.png" />

Here's the kicker: since distance functions are mathematically defined, you can procedurally generate all kinds of distance functions to render all kinds of cool, abstract shapes.

:::tip Confused?

New to ray marching? This guide briefly covers the basics. Here are some great resources in case you're ever feeling lost or in need of inspiration:

- 👉 [Check out this introduction to ray marching from Jamie Wong](http://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions/)
- 👉 [Check out some videos by Inigo Quelez](https://www.youtube.com/channel/UCdmAhiG8HQDlz8uyekw4ENw)
- 👉 [Check out some videos by The Art of Code](https://www.youtube.com/c/TheArtofCodeIsCool)
- 👉 [Check out the wonderful WebGL fundamentals guide](https://webglfundamentals.org/)

If you're feeling good, tread on. Code samples are abundant. You may be able to figure out what you need from this guide alone. If not, come back here after following some more basic tutorials.

:::

:::note

Inigo Quelez has a useful list of signed distance functions on his website. [Bookmark it.](https://www.iquilezles.org/www/articles/distfunctions/distfunctions.html)

:::
