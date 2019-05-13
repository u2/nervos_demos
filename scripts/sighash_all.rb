


def self.sign_sighash_all_inputs(inputs, outputs, privkey)
     s = Ckb::Blake2b.new
      sighash_type = 0x1.to_s
      s.update(sighash_type)
      inputs.each do |input|
       s.update(Ckb::Utils.hex_to_bin(input[:previous_output][:hash]))
        s.update(input[:previous_output][:index].to_s)
     end
      outputs.each do |output|
        s.update(output[:capacity].to_s)
        s.update(Ckb::Utils.hex_to_bin(Ckb::Utils.json_script_to_hash(output[:lock])))
        if output[:type]
         s.update(Ckb::Utils.hex_to_bin(Ckb::Utils.json_script_to_hash(output[:type])))
        end
      end
     key = Secp256k1::PrivateKey.new(privkey: privkey)
      signature = key.ecdsa_serialize(key.ecdsa_sign(s.digest, raw: true))
     signature_hex = Ckb::Utils.bin_to_hex(signature)
      inputs.map do |input|
       args = input[:args] + [signature_hex, sighash_type]
       input.merge(args: args)
     end
   end
