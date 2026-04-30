#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
D-ORCA Video Captioning Script for Windows 10
Processes a single video file and generates audio-visual captions.
Outputs results to the same folder as the input video.
"""

import os
import sys
import torch
import json
from pathlib import Path
from datetime import datetime
import yaml

# Add project root to path
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root))

from qwenvl.train.eval_dorca import process_video_single

def get_device():
    """Get best available device, with CUDA to CPU fallback on OOM."""
    if torch.cuda.is_available():
        try:
            # Try to allocate a small tensor on CUDA to test availability
            torch.zeros(1).cuda()
            print("Using CUDA (GPU)")
            return "cuda"
        except RuntimeError:
            print("CUDA available but failed to allocate. Falling back to CPU.")
            return "cpu"
    else:
        print("CUDA not available. Using CPU.")
        return "cpu"

def main():
    if len(sys.argv) < 2:
        print("Usage: python d_orca_caption.py <video_file>")
        print("Or drag and drop a video file onto D-ORCA.bat")
        sys.exit(1)
    
    video_path = sys.argv[1]
    
    # Validate input file
    if not os.path.exists(video_path):
        print(f"Error: File not found: {video_path}")
        sys.exit(1)
    
    video_path = os.path.abspath(video_path)
    video_dir = os.path.dirname(video_path)
    video_name = os.path.splitext(os.path.basename(video_path))[0]
    
    print(f"Processing: {video_path}")
    print(f"Output will be saved to: {video_dir}")
    
    # Create config for processing
    config = {
        'video_path': video_path,
        'audio_path': None,  # Audio will be extracted from video
        'question': 'Please describe this video comprehensively, focusing primarily on the character dialogue. Identify when, who, and what is said.',
        'interval': 0.5,
        'max_frames': 128,
        'max_new_tokens': 4096,
        'do_sample': True,
        'seed': 2025,
        'output_dir': video_dir,
        'output_filename': f"{video_name}_caption.json"
    }
    
    # Try CUDA first, fallback to CPU on OOM
    device = get_device()
    
    try:
        result = process_video_single(
            video_path=config['video_path'],
            audio_path=config['audio_path'],
            question=config['question'],
            interval=config['interval'],
            max_frames=config['max_frames'],
            max_new_tokens=config['max_new_tokens'],
            do_sample=config['do_sample'],
            seed=config['seed'],
            device=device
        )
        
        # Save output to same folder as input video
        output_path = os.path.join(video_dir, config['output_filename'])
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(result, f, ensure_ascii=False, indent=2)
        
        print(f"\n✓ Caption saved to: {output_path}")
        print(f"\nGenerated Caption:\n{result.get('pred', 'No prediction generated')}")
        
    except torch.cuda.OutOfMemoryError as e:
        print(f"\n⚠ Out of Memory on GPU. Switching to CPU...")
        if device == "cuda":
            torch.cuda.empty_cache()
            device = "cpu"
            print("Retrying with CPU (this will be slower)...")
            try:
                result = process_video_single(
                    video_path=config['video_path'],
                    audio_path=config['audio_path'],
                    question=config['question'],
                    interval=config['interval'],
                    max_frames=config['max_frames'],
                    max_new_tokens=config['max_new_tokens'],
                    do_sample=config['do_sample'],
                    seed=config['seed'],
                    device=device
                )
                
                output_path = os.path.join(video_dir, config['output_filename'])
                with open(output_path, 'w', encoding='utf-8') as f:
                    json.dump(result, f, ensure_ascii=False, indent=2)
                
                print(f"\n✓ Caption saved to: {output_path}")
                print(f"\nGenerated Caption:\n{result.get('pred', 'No prediction generated')}")
            except Exception as e:
                print(f"\n✗ Error during CPU processing: {e}")
                sys.exit(1)
    except Exception as e:
        print(f"\n✗ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
