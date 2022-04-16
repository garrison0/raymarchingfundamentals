import * as twgl from './node_modules/twgl.js/dist/4.x/twgl-full.module.js';

const gl = document.querySelector("#c").getContext("webgl2");
var state = {sliderValue: 0.0};

var receiveMessage = (event) => {
  const message = event.data.message;

  switch (message) {
    case 'getSliderValue':
      state.sliderValue = event.data.value;
      break;
  }
}
window.parent.addEventListener("message", receiveMessage, false);

function init(shaders)
{
  state.programInfo = twgl.createProgramInfo(gl, [shaders['vs'], shaders['fs']]);
  state.bufferInfo = twgl.primitives.createXYQuadBufferInfo(gl);
  requestAnimationFrame(render);
}

function render(time) { 
  time *= 0.001; // milliseconds to seconds

  twgl.resizeCanvasToDisplaySize(gl.canvas, 1.0);
  gl.viewport(0, 0, gl.canvas.clientWidth, gl.canvas.clientHeight);

  const uniforms = {
    uTime: time,
    uResolution: [gl.canvas.clientWidth, gl.canvas.clientHeight],
    uSlider: state.sliderValue
  }

  gl.useProgram(state.programInfo.program);
  twgl.setUniforms(state.programInfo, uniforms);
  twgl.setBuffersAndAttributes(gl, state.programInfo, state.bufferInfo); 
  twgl.drawBufferInfo(gl, state.bufferInfo);

  requestAnimationFrame(render);
}

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
