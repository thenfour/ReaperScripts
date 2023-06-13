
# tenfour-crush #

![image](https://user-images.githubusercontent.com/3672094/209004729-cafc61ea-8dc5-4e5b-ac32-ab431d4616d1.png)

# Feature list #

- High-quality samplerate crushing
- Bitrate reduction
- With dithering & error-diffusion
- Noise gate
- All parameters fully modulateable
- Level compensation during bitcrushing which also helps modulation
- Midside processing and stereo control
- Wet-dry-diff control, to emphasize the effect if desired.

# Parameters #

## Samplecrush frequency ##

This is a logarithmic control, where 50% is 2205 Hz. I know it's awkward to select frequency this way, but it's much more comfortable to sweep frequencies like this rather than linear, but unfortunately Reaper doesn't offer logarithmic scales for parameters.

Sample crushing reduces self-aliasing artifacts by using polynomial approximation of band-limiting ("polyblep"), plus a pre-resampling filter.

## Bitcrush Bits ##

This controls the number of virtual bits to quantize. A value of `1` means `2^1` bits, or, 2 levels. A value of `4` corresponds to `2^4=16` quantization levels.

Partial levels are supported, so this control is fully modulateable.

## Bitcrush Mode ##

Controls the style of quantization performed.

### Rough ###

In this mode, the selected quantization level is performed without regard to zero-crossing. It means at 1 bit, there are only 2 levels: -1 and +1. Zero doesn't exist there. Therefore there's no output value which represets silence. Result = a very noisy signal. Maybe that's what you want.

When sweeping through bit values, the tone of the sound can be less consistent, and very noisy.

Personally I love this mode.

### Safe ###

This mode ensures a zero-crossing, which means silence is always representable. The tone of the sound is also more consistent and cleaner than the "Rough" mode.

## Bitcrush dither amount ##

Select the amount of dithering to add. This only has an effect when dither type is "Noise" or "Error-diffusion".

0.5 is the "mathematically-correct" value which intends to maximally balance the cancellation of quantization noise against the sound of the dithering itself.

1 amplifies the dithering, in case that's your jam. It's not mine.

## Bitcrush dither type ##

### Off ###

Dithering not enabled. When dithering is disabled, the signal is quantized in-place. The resulting tone can sound a bit "square wave" like, or foldback distortion-like.

### Noise ###

Adds white noise to the signal before quantization in order to perturb the signal into quantizing to different levels. White noise is very effective at hiding the tone of quantization noise, but it replaces it with white noise which probably sounds even less musical.

### Error-diffusion ###

Spreads quantization error values to subsequent 8 samples. For image processing it's very effective. For audio it's hard to say whether it really helps much. But at extremely low bitrates it does have a specific sound. For input signals with a lot of acoustic entropy it can improve the sound a bit, but for something like chiptune it tends to just add glitches and artifacts. At least it's *interesting*.

## Bitcrush stereo mode ##

Changes the way stereo channels are processed during bitcrushing.

### Stereo ###

Bitcrushes left and right stereo channels. The resulting stereo image is the same as the input stereo image.

### Safe ###

Bitcrushes the stereo image itself (side channel), and similar to the "Safe" bitcrush mode, ensures a center value. So the resulting sound will be very "mono".

### Rough ###

Bitcrushes the stereo image itself (side channel), but doesn't ensure that a center value exists. The resulting signal will have a more chaotic stereo image.

## Gate enabled? ##

Enables or disables the gate. The gate silences the output signal when the input signal goes silent. There are a couple main reasons for the gate feature:

1. Without a gate, dithering noise will output continuously. Enabling the gate will disable dither noise when the input signal goes silent.
2. Without a gate, bitrate of 1 in "Rough" mode can't represent silence and will basically output full-scale noise. Enabling the gate will prevent this.

## Stereo width ##

Controls the stereo width of the output signal. When low samplerates or bitrates are being used, having a wide stereo image can sound uncharateristic. This is a convenience control to bring the sound into character.

## Mix (dry-wet-diff) ##

At 0, the original dry signal is output. NOTE: there is a very small delay in the signal so it will not "null" with the original signal. The delay is required in order to smoothly dry-wet mix with the delayed wet signal.

At 0.5, you will hear the wet, bitcrushed & samplecrushed signal.

At 1.0, you will hear the difference between the wet & dry signals. This allows you to emphasize the crush effect.








