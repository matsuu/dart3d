#import('dart:html');

/**
 * WebGL Demo made in Dart.
 * This example is heavily inspired by:
 * http://www.netmagazine.com/tutorials/get-started-webgl-draw-square
 */
class WebGLTest {

  WebGLRenderingContext gl;
  WebGLProgram program;
  double aspect;
  bool running = false;
  
  double foobar = 0.5;
  int itemSize = 2; // 2D space
  bool adding = true;
  
  
  WebGLTest() {
    CanvasElement canvas = document.query('#drawHere');
    this.aspect = canvas.width / canvas.height;
    this.gl = canvas.getContext("experimental-webgl");
    this.gl.viewport(0, 0, canvas.width, canvas.height);
  }

  void init() {
    
    // vertex shader source code. uPosition is our variable that we'll
    // use to create animation
    String vsSource = """
    attribute vec2 aPosition;
    void main() {
      gl_Position = vec4(aPosition, 0, 1);
    }
    """;
    
    // fragment shader source code. uColor is our variable that we'll
    // use to animate color
    String fsSource = """
    precision mediump float;
    uniform vec4 uColor;
    void main() {
      gl_FragColor = uColor;
    }""";
    
    // vertex shader compilation
    WebGLShader vs = this.gl.createShader(WebGLRenderingContext.VERTEX_SHADER);
    this.gl.shaderSource(vs, vsSource);
    this.gl.compileShader(vs);
    
    // fragment shader compilation
    WebGLShader fs = this.gl.createShader(WebGLRenderingContext.FRAGMENT_SHADER);
    this.gl.shaderSource(fs, fsSource);
    this.gl.compileShader(fs);
    
    // attach shaders to a WebGL program
    WebGLProgram p = this.gl.createProgram();
    this.gl.attachShader(p, vs);
    this.gl.attachShader(p, fs);
    this.gl.linkProgram(p);
    this.gl.useProgram(p);
    
    /**
     * Check if shaders were compiled properly. This is probably the most painful part
     * since there's no way to "debug" shader compilation
     */
    if (!this.gl.getShaderParameter(vs, WebGLRenderingContext.COMPILE_STATUS)) { 
      print(this.gl.getShaderInfoLog(vs));
    }
    
    if (!gl.getShaderParameter(fs, WebGLRenderingContext.COMPILE_STATUS)) { 
      print(gl.getShaderInfoLog(fs));
    }

    if (!this.gl.getProgramParameter(program, WebGLRenderingContext.LINK_STATUS)) { 
      print(this.gl.getProgramInfoLog(program));
    }

    this.program = p;
  }
  
  /**
   * Rendering loop
   */
  void update() {
    // genereate 3 points (that's 6 items in 2D space) = 1 polygon
    Float32Array vertices = new Float32Array.fromList([
      -this.foobar, this.foobar * aspect,
      this.foobar,  this.foobar * aspect,
      this.foobar, -this.foobar * aspect
    ]);
 
    this.gl.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, this.gl.createBuffer());
    this.gl.bufferData(WebGLRenderingContext.ARRAY_BUFFER,
                       vertices, WebGLRenderingContext.STATIC_DRAW);

    int numItems = (vertices.length / this.itemSize).toInt();
 
    this.gl.clearColor(0.9, 0.9, 0.9, 1);
    this.gl.clear(WebGLRenderingContext.COLOR_BUFFER_BIT);
    
    // set color
    WebGLUniformLocation uColor = gl.getUniformLocation(program, "uColor");
    // as defined in fragment shader source code, color is vector of 4 items
    this.gl.uniform4fv(uColor, [this.foobar, this.foobar, 0.0, 1.0]);

    // set position
    // WebGL knows we want to use 'vertices' for this because
    // we called bindBuffer above (it's maybe a bit unclear but)
    // For more info: http://www.netmagazine.com/tutorials/get-started-webgl-draw-square
    int aPosition = this.gl.getAttribLocation(program, "aPosition");
    this.gl.enableVertexAttribArray(aPosition);
    this.gl.vertexAttribPointer(aPosition, this.itemSize,
                                WebGLRenderingContext.FLOAT, false, 0, 0);
    
    // draw it!
    this.gl.drawArrays(WebGLRenderingContext.TRIANGLES, 0, numItems);
    
    
    // change color and move the triangle a little bit
    this.foobar += (this.adding ? 1 : -1) * this.foobar / 100;
    
    if (this.foobar > 0.9) {
      this.adding = false;
    } else if (this.foobar < 0.2) {
      this.adding = true;
    }
  }

  void run() {
    window.setInterval(f() => this.update(), 50); // that's 20 fps
    this.running = true;
  }
}

void main() {
  WebGLTest demo = new WebGLTest();
  demo.init();
  demo.run();
}