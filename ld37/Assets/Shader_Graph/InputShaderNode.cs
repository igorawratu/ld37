using UnityEngine;
using System.Collections;

public class InputShaderNode : ShaderNode {
	public InputShaderNode() : base("InputShader", 32, 32, true, true)
	{
	}

	public override void Execute()
	{
		Vector4 mouseMove = Vector4.zero;
		mouseMove.x = Input.GetAxis("Mouse X");
		mouseMove.y = Input.GetAxis("Mouse Y");

		material_.SetVector("_mouseMovement", mouseMove);

		Vector4 wasdMove = Vector4.zero;
		if (Input.GetKey (KeyCode.W)) {
			wasdMove.x += 1;
		}
		if (Input.GetKey (KeyCode.S)) {
			wasdMove.x -= 1;
		}
		if (Input.GetKey (KeyCode.A)) {
			wasdMove.y += 1;
		}
		if (Input.GetKey (KeyCode.D)) {
			wasdMove.y -= 1;
		}

		material_.SetVector("_wasdMovement", wasdMove);

		base.Execute();
	}
}
