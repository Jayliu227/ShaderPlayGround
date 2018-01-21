using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class DrawLines : MonoBehaviour {

    public Material material;
    public ComputeShader shader;

    ComputeBuffer buffer;

    int count = 1024;
    float size = 1;

    private void Start()
    {
        buffer = new ComputeBuffer(count, sizeof(float) * 3, ComputeBufferType.Default);

        float[] points = new float[count * 3];

        for (int i = 0; i < count; i++)
        {
            points[i * 3] = Random.Range(-size, size);
            points[i * 3 + 1] = Random.Range(-size, size);
            points[i * 3 + 2] = Random.Range(-size, size);
        }

        buffer.SetData(points);
    }

    private void OnPostRender()
    {
        material.SetPass(0);
        material.SetBuffer("buffer", buffer);
        Graphics.DrawProcedural(MeshTopology.Lines, count, 1);
    }

    private void OnDestroy()
    {
        if(buffer != null)
        {
            buffer.Release();
            Debug.Log("buffer released");
        }
    }
}
