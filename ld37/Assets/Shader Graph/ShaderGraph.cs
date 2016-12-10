﻿using UnityEngine;
using System.Collections;

public class ShaderGraph : MonoBehaviour {
    private ShaderNode _logicNode;
	private InputShaderNode _inputNode;
	private ShaderNode _gameRenderNode;

    // Use this for initialization
    void Start() {
		_inputNode = new InputShaderNode();
		_logicNode = new ShaderNode("GameLogic", 1920, 1080, true);
		_gameRenderNode = new ShaderNode("GameRenderer", 1920, 1080, false);

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
	}

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
		_gameRenderNode.Execute();
        Graphics.Blit(_gameRenderNode.OutputTexture, dest);
    }
}
