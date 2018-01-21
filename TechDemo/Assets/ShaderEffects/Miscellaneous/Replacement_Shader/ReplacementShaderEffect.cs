using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ReplacementShaderEffect : MonoBehaviour {

	public Shader ReplacementShader;
	public Color OverAllColor;

	void OnValidate(){
		Shader.SetGlobalColor ("_OverAllColor", OverAllColor);
	}

	void OnEnable(){
		if (ReplacementShader != null) {
			// the second argument means:
			/*
				which tag to check in the shaders being replaced.
				and this means that all the shaders with a subshdaer where there is a RenderType
				that matches the RenderType of the Replacement Shader.

				if there is no such subshader, than this object would not be rendered.

				would we want more than one kind of tags to be the checker, we can have more subshaders in
				our ReplacementShader with different tag value (same tag though)

				if the second argument is set to "", then all the obj would be replaced by the FIRST subshader
				defined in the ReplacementShader.
			*/
			GetComponent<Camera> ().SetReplacementShader (ReplacementShader, "");
		}
	}

	// remember to reset the replacement shader here!
	void OnDisable(){
		GetComponent<Camera> ().ResetReplacementShader ();
	}
}
