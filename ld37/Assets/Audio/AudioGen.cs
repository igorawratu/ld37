using UnityEngine;
using System.Collections;

public class AudioGen : MonoBehaviour
{
	// Notes in hz
	const float NoteA = 440.0f;
	const float NoteC3 = 130.81f;
	const float NoteC4 = 261.6f;
	const float NoteC2 = 65.41f;
	const float NoteC8 = 4186.01f;


	private float t;
	private float _sampleRate;

	private float[] _randomBuffer = new float[4096];
	private System.Random _rand = new System.Random();
	private float _sampleStep;

	void Awake()
	{
		_sfxHit = -100f;

		_sampleRate = AudioSettings.outputSampleRate;
		_sampleStep = 1f / (float)_sampleRate;
		//Debug.Log(AudioSettings.outputSampleRate);
		for (int i = 0; i < _randomBuffer.Length; i++)
		{
			_randomBuffer[i] = UnityEngine.Random.Range(-1f, 1f);
		}
		//Application.targetFrameRate = 60;
	}

	private int _offset;
	/*
	void OnAudioFilterRead(float[] values, int numChannels)
	{
		int numSamples = values.Length;

		_offset++;

		float counter = 0f;
		float freq = 4f;
		int x = _offset % _randomBuffer.Length;
		float nextValue = _randomBuffer[x];
		for (int i = 0; i < numSamples; i++)
		{
			values[i] = nextValue;

			counter++;
			if (counter > freq)
			{
				counter -= freq;
				x = x + 1;
				x %= _randomBuffer.Length;
				nextValue = _randomBuffer[x];
			}
		}
	}*/

	private static float GenSquare(float t)
	{
		return Mathf.Sign(Mathf.Sin(t * Mathf.PI * 2f));
	}

	private static float GenSine(float t)
	{
		return Mathf.Sin(t * Mathf.PI * 2f);
	}

	private static float GenSaw(float t)
	{
		return (Mathf.Repeat(t, 1f) - 0.5f) * 2f;
	}

	private static float GenTriangle(float t)
	{
		return ((Mathf.Abs(Mathf.Repeat(t * 2f, 2f) - 1f) - 0.5f) * 2f);
	}

	private float GenNoise(float t)
	{
		int ro = (int)(t);
		ro %= _randomBuffer.Length;
		return _randomBuffer[ro];
	}

	private float Mix(float a, float b)
	{
		return (a + b) * 0.8f;// (a + b) - (a * b);
	}

	private static float EnvADSR(float t, float volAttack, float volSustain, float a, float d, float s, float r)
	{
		// Attack
		if (t < a)
		{
			return (t / a) * volAttack;
		}
		t -= a;
		// Decay
		if (t < d)
		{
			return Mathf.Lerp(volAttack, volSustain, (t / d));
		}
		t -= d;
		// Sustain
		if (t < s)
		{
			return volSustain;
		}
		t -= s;
		// Release
		if (t < r)
		{
			return Mathf.Lerp(volSustain, 0f, t / r);
		}
		return 0f;
	}

	//private static float Song[];

	private float _sfxHit;

	private void Update()
	{
		//_sfxHit = -100f;
		if (Input.anyKeyDown)
		{
			_sfxHit = t;
		}
		
	}

	void OnAudioFilterRead(float[] values, int numChannels)
	{
		// 48000 samples / second
		int numSamples = values.Length;

		float offset = _sampleStep;

		//t = count * values.Length * _sampleStep;
		//count++;

		for (int i = 0; i < numSamples; i++)
		{
			values[i] = 0f;

			//values[i] = ((GenSine(t * NoteC4) + GenSine(t * NoteC2) + GenSine(t * NoteC8)) / 3f) * EnvADSR(t, 1f, 0.5f, 0.1f, 0.1f, 0.2f, 0.1f);
			//values[i] = GenSaw(t * NoteC4);

			//float sfxHit = GenNoise(t * NoteC4 * 100f) * EnvADSR(t - _sfxHit, 1f, 0.25f, 0.03f, 0.0f, 0.0f, 0.03f);
			//float sfxHit = GenSine(t * NoteC4) * EnvADSR(t - _sfxHit, 1f, 0.5f, 0.2f, 0.1f, 0.5f, 0.2f);
			float sfxHit = (GenSine((t + 0.5f) * NoteC4) - GenSaw(t * NoteC8)) * EnvADSR(t - _sfxHit, 1f, 0.5f, 0.1f, 0.0f, 0.2f, 0.2f);

			float drum = GenNoise(t * NoteC4 * 10f) * EnvADSR(Mathf.Repeat(t, 1f), 1f, 0.25f, 0.02f, 0.00f, 0.0f, 0.02f);
			float hihat = GenNoise(t * NoteC4 * 100f) * EnvADSR(Mathf.Repeat(t, 2f), 1f, 0.25f, 0.01f, 0.05f, 0.0f, 0.0f);

			float deepBass = Mix(GenSine(t * NoteC2), GenSine(t * NoteC2 / 2f));

			values[i] = Mix(values[i], drum);
			values[i] = Mix(values[i], sfxHit);
			values[i] = Mix(values[i], deepBass);
			//values[i] = ((Mathf.Abs(Mathf.Repeat(t * 2f, 2f) - 1f) - 0.5f) * 2f);          // Triangle (correct)

			//values[i] = GenSquare(t * NoteC4) * EnvADSR(t, 1f, 0.5f, 0.1f, 0.1f, 0.2f, 0.1f);

			/*int ro = (int)(t);
			ro %= _randomBuffer.Length;
			values[i] = _randomBuffer[ro];*/

			t += offset;

			values[i] = Mathf.Clamp01(values[i] * 0.5f);
		}
	}
}
