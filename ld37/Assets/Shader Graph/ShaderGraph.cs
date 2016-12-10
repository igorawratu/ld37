using UnityEngine;
using System.Collections;

public class ShaderGraph : MonoBehaviour {
    private ShaderNode _finalNode;

    // Use this for initialization
    void Start() {
		//_finalNode = new ShaderNode("test", 1920, 1080, false);
		_finalNode = new ShaderNode("ChromaAberration", 1920, 1080, false);

		Texture2D tex = Resources.Load("Textures/test_tex") as Texture2D;
		Debug.Log(tex);
		//_finalNode.SetPredecessor(_finalNode, "_MainTex");
		_finalNode.SetTexture(tex, "_MainTex");
    }

    // Update is called once per frame
    void Update() {
        
    }

    void OnDestroy()
    {
        _finalNode.Release();
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        _finalNode.Execute();
        Graphics.Blit(_finalNode.OutputTexture, dest);
    }
}
