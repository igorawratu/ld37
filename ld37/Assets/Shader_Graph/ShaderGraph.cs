using UnityEngine;
using System.Collections;

public class ShaderGraph : MonoBehaviour {
    private ShaderNode _logicNode;
	private InputShaderNode _inputNode;
	private ShaderNode _gameRenderNode;
	private ShaderNode _textNode;

    // Use this for initialization
    void Start() {
		_inputNode = new InputShaderNode();
		_logicNode = new ShaderNode("GameLogic", 1920, 1080, true, true);
		_gameRenderNode = new ShaderNode("GameRenderer", 1920, 1080, false, true);
		_textNode = new ShaderNode("Text", 1920, 1080, false, true);

		_logicNode.SetPredecessor(_inputNode, "_inputTex");
		_logicNode.SetPredecessor(_logicNode, "_MainTex");
		_gameRenderNode.SetPredecessor(_logicNode, "_MainTex");

	}

    // Update is called once per frame
    void Update() {
        
    }

    void OnDestroy()
    {
		_logicNode.Release();
		_inputNode.Release();
		_gameRenderNode.Release();
		_textNode.Release();
	}

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
		_textNode.Execute();
        Graphics.Blit(_textNode.OutputTexture, dest);
    }
}
