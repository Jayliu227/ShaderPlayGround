using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InvokeComputeShader : MonoBehaviour {

    public ComputeShader shader, shaderCopy;
    private RenderTexture tex, texCopy;
	
	void Start () {
        useTextureShader();
    }

    private void OnGUI()
    {
        int w = Screen.width / 2;
        int h = Screen.height / 2;
        int s = 512;

        GUI.DrawTexture(new Rect(w - s / 2, h - s / 2, s, s), texCopy);
    }

    private void OnDestroy()
    {
        tex.Release();
        texCopy.Release();
    }

    void useTextureShader()
    {
        // the third arguments indicates if we want depth buffer.
        tex = new RenderTexture(64, 64, 0);
        // set this flag on, so that compute shader can rw it.
        tex.enableRandomWrite = true;
        // all the setup needs to be done before it actually creates the texture.
        tex.Create();

        texCopy = new RenderTexture(64, 64, 0);
        texCopy.enableRandomWrite = true;
        texCopy.Create();

        /*
        shader.SetTexture(0,"tex", tex);
        // because for each dimension, say x.
        /*
            since one group contains numthread.x number of threads
            we only need total number of threads needed / numofthreads per group, that many groups

            x threads required / number of threads per group = number of groups
         
        shader.Dispatch(0, tex.width / 8, tex.height / 8, 1);
        */
        // won't display anything because now tex is nothing
        shaderCopy.SetTexture(0, "tex", tex);
        shaderCopy.SetTexture(0, "texCopy", texCopy);
        shaderCopy.Dispatch(0, texCopy.width / 8, texCopy.height / 8, 1);

        /*
            3D texture:

            RenderTexture 3dTex = new RenderTexture(Width, Height, 0);
            3dTex.volumeDepth = Depth;
            3dTex.isVolumetric = true;
            3dTex.enableRandomWrite = true;
            3dTex.Create();

            // remember to set the third dimension in Dispatch Function    
         */
    }

    void useSimpleShader()
    {
        ComputeBuffer buffer = new ComputeBuffer(4 * 4 * 2 * 2, sizeof(int));
        int kernal = shader.FindKernel("CSMain1");
        shader.SetBuffer(kernal, "buffer2", buffer);
        shader.Dispatch(kernal, 2, 2, 1);

        int[] resultData = new int[4 * 4 * 2 * 2];
        buffer.GetData(resultData);

        for (int i = 0; i < 8; i++)
        {
            string line = "";
            for (int j = 0; j < 8; j++)
            {
                line += " " + resultData[j + i * 8];
            }
            Debug.Log(line);
        }

        buffer.Release();
    }
}
