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
		_sampleRate = AudioSettings.outputSampleRate;
		_sampleStep = 1f / (float)_sampleRate;
		//Debug.Log(AudioSettings.outputSampleRate);
		for (int i = 0; i < _randomBuffer.Length; i++)
		{
			_randomBuffer[i] = UnityEngine.Random.value;
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

	void OnAudioFilterRead(float[] values, int numChannels)
	{
		// 48000 samples / second
		int numSamples = values.Length;

		float offset = _sampleStep;

		//t = count * values.Length * _sampleStep;
		//count++;

		for (int i = 0; i < numSamples; i++)
		{
			//values[i] = GenSquare(t * NoteC8) * EnvADSR(t, 1f, 0.5f, 0.1f, 0.1f, 0.2f, 0.1f);
			//values[i] = GenSine(t * NoteC4) * EnvADSR(t, 1f, 0.5f, 0.2f, 0.1f, 0.5f, 0.2f);

			values[i] = ((GenSine(t * NoteC4) + GenSine(t * NoteC2) + GenSine(t * NoteC8)) / 3f) * EnvADSR(t, 1f, 0.5f, 0.1f, 0.1f, 0.2f, 0.1f);
			//values[i] = GenSaw(t * NoteC4);
			//values[i] = GenNoise(t * NoteC8);
			//values[i] = ((Mathf.Abs(Mathf.Repeat(t * 2f, 2f) - 1f) - 0.5f) * 2f);          // Triangle (correct)

			/*int ro = (int)(t);
			ro %= _randomBuffer.Length;
			values[i] = _randomBuffer[ro];*/

			t += offset;
		}
	}
}
