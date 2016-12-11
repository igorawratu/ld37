using UnityEngine;
using System.Collections;

public class Sounds : AudioGen
{
	enum Types
	{
		Hit,
		Teleport1,
		Teleport2,
		Positive,
		Whistle,
		Bat,
		Wobble,
	}

	public ShaderGraph _graph;
	private Texture2D _readableLogicTexture;
	private float[] _sfxTriggerTimes = new float[System.Enum.GetNames(typeof(Sounds.Types)).Length];

	public override void Awake()
	{
		for (int i = 0; i < _sfxTriggerTimes.Length; i++)
		{
			_sfxTriggerTimes[i] = -100f;
		}
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

		// DEBUG: Trigger from keybaord numbers
		for (int i = 0; i < _sfxTriggerTimes.Length; i++)
		{
			if (Input.GetKeyDown(KeyCode.Alpha1 + i))
			{
				_sfxTriggerTimes[i] = t;
			}
		}
	}

	void OnAudioFilterRead(float[] values, int numChannels)
	{
		int numSamples = values.Length;

		float offset = _sampleStep;

		for (int i = 0; i < numSamples; i++)
		{
			values[i] = 0f;

			
			//float sfxHit = GenSine(t * Mathf.Lerp(NoteC2, NoteC4, hitEnv)) * hitEnv;

			//float sfxHit = GenTriangle((t + 0.25f) * NoteC4) * GenTriangle((t + 0.5f) * NoteC4) * GenSquare(t * NoteC4) * hitEnv;

			//float sfxHit = GenSine(t * NoteC4 + (GenTriangle(t * NoteC3) * 1f)) * hitEnv;

			// SFX HIT
			{
				float env = EnvADSR(t - _sfxTriggerTimes[(int)Types.Hit], 1f, 0.25f, 0.1f, 0.1f, 0.1f, 0.1f);
				float phaseShift = GenSaw(t * NoteC1) * 2f;
				float sfxHit = GenSine(t * NoteC4 + phaseShift) * env;
				values[i] = Mix(values[i], sfxHit);
			}
			
			// SFX SPAWN
			{
				float env = EnvADSR(t - _sfxTriggerTimes[(int)Types.Teleport1], 1f, 0.25f, 0.1f, 0.1f, 0.1f, 0.1f);
				float phaseShift2 = GenSine(t * NoteC1) * 0.01f;
				float phaseShift = GenSine((t + phaseShift2) * NoteC3) * 0.01f;
				float sfxSpawn = GenSine((t + phaseShift) * NoteC4) * env;
				sfxSpawn = opQuatiseBits(sfxSpawn, 12);
				values[i] = Mix(values[i], sfxSpawn);
			}

			// SFX 3
			{
				float env = EnvADSR(t - _sfxTriggerTimes[(int)Types.Teleport2], 1f, 0.25f, 0.1f, 0.1f, 0.1f, 0.1f);
				float phaseShift2 = GenSine(t * NoteC1) * 0.01f;
				float phaseShift = GenSine((t + phaseShift2) * NoteC3) * 0.01f;
				float sfx = GenSine((t + phaseShift2) * NoteC4) * env;
				values[i] = Mix(values[i], sfx);
			}

			// SFX 4 - positive
			{
				float env = EnvADSR(t - _sfxTriggerTimes[(int)Types.Positive], 1f, 0.25f, 0.1f, 0.1f, 0.5f, 0.1f);
				float phaseShift = env;
				float sfx = GenTriangle((t + phaseShift) * NoteC4) * env;
				values[i] = Mix(values[i], sfx);
			}

			// SFX 5 - whistle
			{
				float env = EnvADSR(t - _sfxTriggerTimes[(int)Types.Whistle], 1f, 0.25f, 0.1f, 0.1f, 0.5f, 0.1f);
				float phaseShift = env * env;
				float sfx = GenTriangle((t + phaseShift) * NoteC4) * env;
				values[i] = Mix(values[i], sfx);
			}

			// SFX 6 - bat
			{
				float env = EnvADSR(t - _sfxTriggerTimes[(int)Types.Bat], 1f, 0.25f, 0.1f, 0.1f, 0.5f, 0.1f);
				float phaseShift = -Mathf.Abs(env);
				float sfx = GenSine(Mathf.Max(0f, t + phaseShift) * NoteC4 * 1f * 0.5f) * GenSine(Mathf.Max(0f, t + phaseShift) * NoteC4 * 1f) * env;
				values[i] = Mix(values[i], sfx * 0.25f);
			}

			// SFX 7 - wobble
			{
				float tt = t - _sfxTriggerTimes[(int)Types.Wobble];
				float env = EnvADSR(tt, 1f, 0.25f, 0.1f, 0.1f, 0.5f, 0.1f);
				float phaseShift = GenSine(tt) * GenTriangle(tt);
				float vibrato = Mathf.PingPong(tt, 2.5f) / 2.5f;
				float deepBass = vibrato * Mix(GenSine((t + phaseShift) * NoteC4), GenSine((t + 0.5f + phaseShift) * NoteC3)) * env;
				values[i] = Mix(values[i], deepBass * 2.0f);
			}

			t += offset;

			values[i] = Mathf.Clamp01(values[i] * 0.5f);
		}
	}
}