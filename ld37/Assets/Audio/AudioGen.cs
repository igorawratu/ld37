using UnityEngine;
using System.Collections;

public class AudioGen : MonoBehaviour
{
	// Notes in hz
	protected const float NoteA = 440.0f;
	protected const float NoteC1 = 32.70f;
	protected const float NoteC3 = 130.81f;
	protected const float NoteC4 = 261.6f;
	protected const float NoteD4 = 293.66f;
	protected const float NoteDS4 = 311.13f;
	protected const float NoteE4 = 329.63f;
	protected const float NoteC2 = 65.41f;
	protected const float NoteC8 = 4186.01f;


	protected float t;
	protected float _sampleRate;

	protected float[] _randomBuffer = new float[4096];
	protected System.Random _rand = new System.Random();
	protected float _sampleStep;

	public virtual void Awake()
	{
		_sampleRate = AudioSettings.outputSampleRate;
		_sampleStep = 1f / (float)_sampleRate;
		//Debug.Log(AudioSettings.outputSampleRate);
		for (int i = 0; i < _randomBuffer.Length; i++)
		{
			_randomBuffer[i] = UnityEngine.Random.Range(-1f, 1f);
		}
	}

	protected int _offset;

	protected static float GenSquare(float t)
	{
		return Mathf.Sign(Mathf.Sin(t * Mathf.PI * 2f));
	}

	protected static float GenSine(float t)
	{
		return Mathf.Sin(t * Mathf.PI * 2f);
	}

	protected static float GenSaw(float t)
	{
		return (Mathf.Repeat(t, 1f) - 0.5f) * 2f;
	}

	protected static float GenTriangle(float t)
	{
		return ((Mathf.Abs(Mathf.Repeat(t * 2f, 2f) - 1f) - 0.5f) * 2f);
	}

	protected float GenNoise(float t)
	{
		int ro = (int)(t);
		ro %= _randomBuffer.Length;
		return _randomBuffer[ro];
	}

	protected float Mix(float a, float b)
	{
		return (a + b);// (a + b) - (a * b);
	}

	protected static float EnvADSR(float t, float volAttack, float volSustain, float a, float d, float s, float r)
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

	protected static float opQuatiseBits(float x, int bits)
	{
		int a = (int)(x * 65536f);
		a >>= bits;
		a <<= bits;
		return (float)a / 65536f;
	}

	private float[] _leadSong = 
	{ 
		NoteC4,
		0,
		NoteD4,
		0,

		NoteDS4,
		0,
		NoteC4,
		NoteC4,

		0,
		NoteE4,
		NoteC4,
		0,

		NoteDS4,
		0,
		0,
		0,
	};

	private float[] _bassSong = { NoteC4, NoteC3, NoteC4, NoteC4, NoteC4, NoteC3 };

	
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

			float drum = GenNoise(t * NoteC4 * 10f) * EnvADSR(Mathf.Repeat(t, 1f), 1f, 0.25f, 0.02f, 0.00f, 0.0f, 0.02f);

			float vibrato = Mathf.PingPong(t, 2.5f) / 2.5f;

			float hihat = GenNoise(t * NoteC4 * 100f) * EnvADSR(Mathf.Repeat(t, 2f), 1f, 0.25f, 0.01f, 0.05f, 0.0f, 0.0f);

			// deep bass
			{
				float rowsPerSecond = 1f;
				int songRow = (int)(t / rowsPerSecond);
				float bassFreq = _bassSong[songRow % _bassSong.Length];
				float deepBass = vibrato * Mix(GenSine(t * bassFreq / 2f), GenSine((t + 0.5f) * bassFreq / 4f));
				values[i] = Mix(values[i], deepBass * 0.25f);

				//deepBass *= vibrato * Mix(GenSquare(t * bassFreq / 2f), GenSaw((t + 0.25f) * bassFreq / 4f));
			}

			// lead
			{
				float rowsPerSecond = 4f;
				int songRow = (int)(t * rowsPerSecond);
				float leadHit = Mathf.Clamp01(_leadSong[songRow % _leadSong.Length]);
				float leadFreq = _leadSong[songRow % _leadSong.Length];

				float rowTime = (float)songRow / rowsPerSecond;
				float tWrapped = t;
				leadHit *= EnvADSR(tWrapped - rowTime, 1f, 0.25f, 0.05f, 0.05f, 0.2f, 0.02f);
				float lead = GenTriangle(t * leadFreq) * leadHit;
				values[i] = Mix(values[i], lead);
			}


			//sfxHit = opQuatiseBits(sfxHit, 14);
			//hihat = opQuatiseBits(hihat, 24);

			//values[i] = Mix(values[i], drum);
			//values[i] = Mix(values[i], hihat);
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
