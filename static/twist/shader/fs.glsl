#version 300 es

precision highp float;

in vec2 vUv;
uniform vec2 uResolution;
uniform float uTime;
uniform float uSlider;

out vec4 o_FragColor;

float sdRoundBox( vec3 p, vec3 b, float r )
{
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

vec2 map (vec3 p, float time) 
{ 
    vec2 res = vec2(1e10, 0.0);

    p = p + vec3(0.0, 0.0, 15.0);

    // twist
    // float k = (sin(time*0.35))*2.75; 
    float k = uSlider / 40.0; 
    float c = cos(k*p.y);
    float s = sin(k*p.y);
    mat2  m = mat2(c,-s,s,c);
    vec3 twisted = vec3(m*p.xz,p.y);

    res = vec2(sdRoundBox(twisted, vec3(0.5), 0.0), 15.0);

    return res;
}

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

vec3 calcNormal( in vec3 p, float time )
{
    const float eps = 0.0001; 
    const vec2 h = vec2(eps,0);
    return normalize( vec3(map(p+h.xyy, time).x - map(p-h.xyy, time).x,
                        map(p+h.yxy, time).x - map(p-h.yxy, time).x,
                        map(p+h.yyx, time).x - map(p-h.yyx, time).x ) );
}

vec3 render(in vec3 ro, in vec3 rd, float time) 
{ 
    vec3 col = vec3(0.95);

    vec2 res = raycast(ro,rd, time);
    float t = res.x;
    float m = res.y;

    vec3 pos = ro + rd*t;
    vec3 lig = normalize(vec3(0.0, 2.0, 1.0));
    
    vec3 lin = vec3(0);
    vec3 mat = vec3(0.65);

    // lighting
    if ( m > 5.0 ) { 
        vec3 nor = calcNormal(pos, time);
        lin += mat * (0.1 + 0.75 * dot(lig, nor));

        float bou = clamp( 0.3-0.7*nor.y, 0.0, 1.0 );
        lin += 0.8 * mat * vec3(0.5,0.41,0.39) * bou;

        col = lin;
    }
    
    return vec3( clamp(col, 0.0, 1.0) );
}

mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
    vec3 cw = normalize(ta-ro);
    vec3 cp = vec3(sin(cr), cos(cr),0.0);
    vec3 cu = normalize( cross(cw,cp) );
    vec3 cv =          ( cross(cu,cw) );
    return mat3( cu, cv, cw );
}

void main() {
    // camera
    vec3 ro = vec3( 0.0, 3.5, 1.0);
    vec3 ta = vec3( 0.0, 3.275, 0.0);

    mat3 ca = setCamera(ro, ta, 0.0);
    float aspect = uResolution.x / uResolution.y;
    
    vec2 p = vec2(aspect, 1.0) * (vUv - vec2(0.5));
    float time = uTime;

    // ray direction
    vec3 rd = ca * normalize( vec3(p, 5.0) );

    vec3 col = render( ro, rd, time );
    col = pow(col, vec3(0.4545));

    o_FragColor = vec4( col, 1.0 );
}