using UnityEngine;
using System.Collections;

public class OutLine : MonoBehaviour
{

	[SerializeField] Shader shader;
	[SerializeField] Color edgeColor;
	Material mat;

	void Start ()
	{
		var cam = Camera.main;
		cam.depthTextureMode = DepthTextureMode.Depth;
	}

	void OnRenderImage (RenderTexture src, RenderTexture dest)
	{
		if (mat == null) {
			mat = new Material (shader);
		}

		mat.SetColor ("_EdgeColor", edgeColor);
		Graphics.Blit (src, dest, mat);
	}
}
