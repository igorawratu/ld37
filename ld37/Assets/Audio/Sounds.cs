using UnityEngine;
using System.Collections;

public class Sounds : AudioGen
{
	public ShaderGraph _graph;
	private Texture2D _readableLogicTexture;
	private float _sfxHit;

	public override void Awake()
	{
		_sfxHit = -100f;
		base.Awake();
	}

	private void OnDestroy()
	{
		if (_readableLogicTexture != null)
		{
			Texture2D.Destroy(_readableLogicTexture);
			_readableLogicTexture = null;
		}
	}

	// Update is called once per frame
	void Update()
	{
		RenderTexture logicTexture = _graph.GetLogicTexture();

		// Create readable texture
		if (_readableLogicTexture == null)
		{
			_readableLogicTexture = new Texture2D(logicTexture.width, logicTexture.height, TextureFormat.RGBAFloat, false);
			_readableLogicTexture.Apply(false, false);
		}

		// Update readable texture
		if (_readableLogicTexture != null)
		{
			RenderTexture.active = logicTexture;
			_readableLogicTexture.ReadPixels(new Rect(0, 0, logicTexture.width, logicTexture.height), 0, 0, false);
			RenderTexture.active = null;
		}

		// Read state out of texture and trigger sound effects
		Color c1 = _readableLogicTexture.GetPixel(0, 0);
		//Debug.Log(c1.r.ToString("F4") + " " + c1.g.ToString("F4") + " " + c1.b.ToString("F4") + " " + c1.a.ToString("F4"));

		if (Input.anyKeyDown || c1.r > 0.0f)
		{
			_sfxHit = t;
		}
	}

	void OnAudioFilterRead(float[] values, int numChannels)
	{
		int numSamples = values.Length;

		float offset = _sampleStep;

		for (int i = 0; i < numSamples; i++)
		{
			values[i] = 0f;

			float hitEnv = EnvADSR(t - _sfxHit, 1f, 0.5f, 0.1f, 0.0f, 0.2f, 0.2f);
			float sfxHit = GenSine(t * Mathf.Lerp(NoteC2, NoteC4, hitEnv)) * hitEnv;

			values[i] = Mix(values[i], sfxHit);

			t += offset;

			values[i] = Mathf.Clamp01(values[i] * 0.5f);
		}
	}
}