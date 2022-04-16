import React, { useState } from 'react';
import styles from './WebGL.module.css';

export default function WebGL() {
  const [val, setVal] = useState(0);

  function onInput(event) { 
    setVal(event.target.value);
    window.parent.postMessage({ message: "getSliderValue", value: event.target.value }, "*");
  }

  return (
    <div className={styles.wrapper}>
      <iframe src="/twist/"> </iframe>
      <input type="range" style={{height: '100%'}} min="0" max="100" value={val} onChange={onInput}></input>
    </div>
  )
}