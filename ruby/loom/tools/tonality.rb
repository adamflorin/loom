# 
#  tonality.rb: tools for bootstrap JI tuning (see config/scales.yml).
#  also helpers for pitch bends, MIDI notes, etc.
#  
#  Copyright November 2010, Adam Florin. All rights reserved.
# 
require "yaml"

module Loom
  module Tools
    module Tonality

      CONFIG_DIR = File.join(File.dirname(__FILE__), '..', '..', '..', 'config')

      # tune the world to C
      BASE_PITCH = 60

      attr :scales, :scale_id

      # math util.
      # 
      # TODO: cache coefficients after 1st calc
      # 
      def ratio_to_pitch_bend(ratio)
        pitch_bend = if ratio > 0
          # ratio to midi note (0 = unison)
          note_delta = (12.0 / Math.log(2)) * Math.log(ratio)

          # then to 14-bit pitch bend
          (note_delta/12.0 + 1.0) * 8192.0
        else
          0
        end
        return pitch_bend
      end

      # util.
      # 
      def midi_pitch_to_frequency(midi_note)
        return (440.0 * Math.exp(0.057762265 * (midi_note - 69.0)))
      end
      
      # Just load up the array of ratios for the current scale,
      # all as float (never strings)
      # 
      def scale_ratios
        @scales[@scale_id.to_s].map{|p| (p.is_a? String) ? eval(p) : p}
      end

      # For now, just round to nearest scalar tone
      # 
      # TODO: variable amount of gravity toward nearest_scale_ratio,
      # Gaussian distribution around it (?)
      # 
      def fit_to_scale(rough_ratio)
        nearest_scale_ratio = 0 # FIXME: why not 1.0?

        if rough_ratio > 0
          rough_tonic = 2 ** (Math.log(rough_ratio) / Math.log(2)).floor

          ratios_and_deltas = scale_ratios.map do |scale_ratio|

            # bring scale_ratio into rough_ratio's 8ve
            scale_ratio *= 2 while scale_ratio < rough_tonic
            scale_ratio /= 2 while scale_ratio > (rough_tonic * 2)

            delta = (rough_ratio - scale_ratio).abs
            {:scale_ratio => scale_ratio, :delta => delta}
          end

          # FIXME!!!!!!!!!!!! HUGE FUCKING BUG; MAKES NO SENSE!
          # says delta is nil, when it's obviously not!!
          # 
          ratios_and_deltas.each do |rd|
            if rd[:delta].nil?
              error "NULL DELTA! #{rd.inspect}" 
              return 0
            end
          end

          nearest_scale_ratio = ratios_and_deltas.sort{|x, y| x[:delta] <=> y[:delta]}.first[:scale_ratio]
        end

        return nearest_scale_ratio
      end


      private

        def load_scales
          @scales = {}
          @scales.update(YAML.load(File.read("#{CONFIG_DIR}/scales.yml")))
        end

    end
  end
end
