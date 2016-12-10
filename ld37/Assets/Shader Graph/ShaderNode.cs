using UnityEngine;
using System;
using System.Collections.Generic;

public class ShaderNode
{
    public const uint MAX_WIDTH = 4096;
    public const uint MAX_HEIGHT = 4096;

    protected Shader shader_ = null;
	protected Material material_ = null;
	protected RenderTexture [] output_ = null;
	protected uint curr_texture_ = 0;

	protected Dictionary<string, ShaderNode> predecessors_;
	protected Dictionary<string, Texture> input_textures_;

	protected ulong last_frame_num_ = 0;

    public RenderTexture OutputTexture
    {
        get { return output_[curr_texture_]; }
    }

    public ShaderNode(string shader_name, uint width, uint height, bool highres)
    {
        shader_ = Shader.Find(shader_name);
        if(shader_ == null)
        {
            throw new Exception("Unable to find shader " + shader_);
        }

        if(width > MAX_WIDTH || height > MAX_HEIGHT || width == 0 || height == 0)
        {
            throw new Exception("Shader node output dimensions invalid");
        }

        output_ = new RenderTexture[2];

		RenderTextureFormat format = highres ? RenderTextureFormat.ARGBFloat : RenderTextureFormat.ARGB32;
		for (int i = 0; i < 2; ++i)
        {
            output_[i] = new RenderTexture((int)width, (int)height, 0, format);
        }

        predecessors_ = new Dictionary<string, ShaderNode>();
        input_textures_ = new Dictionary<string, Texture>();

        material_ = new Material(shader_);
    }

    public void Release()
    {
        if(output_ != null)
        {
            for(int i = 0; i < output_.Length; ++i)
            {
                if(output_[i] != null)
                {
                    output_[i].Release();
                }
            }
            output_ = null;
        }

        if(material_ != null)
        {
            Material.Destroy(material_);
            material_ = null;
        }
    }

    public void SetTexture(Texture texture, string input_name)
    {
        input_textures_[input_name] = texture;
    }

    public void SetPredecessor(ShaderNode predecessor, string input_name)
    {
        predecessors_[input_name] = predecessor;
    }

    public virtual void Execute()
    {
        if((ulong)Time.frameCount == last_frame_num_)
        {
            return;
        }

        last_frame_num_ = (ulong)Time.frameCount;

        foreach (var predecessor in predecessors_)
        {
            if (predecessor.Value != this)
            {
                predecessor.Value.Execute();
                material_.SetTexture(predecessor.Key, predecessor.Value.OutputTexture);
				Vector4 texelsize = Vector4.zero;
				if(predecessor.Value.OutputTexture != null)
				{
					texelsize.x = 1f / predecessor.Value.OutputTexture.width;
					texelsize.y = 1f / predecessor.Value.OutputTexture.height;
					texelsize.z = predecessor.Value.OutputTexture.width;
					texelsize.w = predecessor.Value.OutputTexture.height;
				}
				material_.SetVector(predecessor.Key + "_TexelSize", texelsize);
            }
        }
        
        foreach(var texture in input_textures_)
        {
            material_.SetTexture(texture.Key, texture.Value);

			Vector4 texelsize = Vector4.zero;
			if (texture.Value != null)
			{
				texelsize.x = 1f / texture.Value.width;
				texelsize.y = 1f / texture.Value.height;
				texelsize.z = texture.Value.width;
				texelsize.w = texture.Value.height;
			}

			material_.SetVector(texture.Key + "_TexelSize", texelsize);
		}

        Texture main = null;

        if (predecessors_.ContainsKey("_MainTex"))
        {
            main = predecessors_["_MainTex"].OutputTexture;
        }
        else if(input_textures_.ContainsKey("_MainTex"))
        {
            main = input_textures_["_MainTex"];
        }

        material_.SetFloat("_t", Time.time);

		curr_texture_ = (curr_texture_ + 1) % 2;

		material_.SetFloat("_width", output_[curr_texture_].width);
		material_.SetFloat("_height", output_[curr_texture_].height);

		Graphics.Blit(main, output_[curr_texture_], material_);
    }
}
