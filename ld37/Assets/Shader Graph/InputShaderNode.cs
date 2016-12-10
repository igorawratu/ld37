using UnityEngine;
using System.Collections;

public class InputShaderNode : ShaderNode {
	public InputShaderNode() : base("InputShader", 1920, 1080, true)
	{
	}

	public override void Execute()
	{
		Vector4 mouseMove = Vector4.zero;
		mouseMove.x = Input.GetAxis("Mouse X");
		mouseMove.y = Input.GetAxis("Mouse Y");

		material_.SetVector("_mouseMovement", mouseMove);
		base.Execute();
	}
}
