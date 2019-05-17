if ARGV.length != 2
   raise "Wrong number of arguments!"
end

def hex_to_bin(s)
 if s.start_with?("0x")
    s = s[2..-1]
  end
  [s].pack("H*")
end

tx = CKB.load_tx_hash

pubkey = ARGV[0]
signature = ARGV[1]

unless Secp256k1.verify(hex_to_bin(pubkey), hex_to_bin(signature), hash)
  raise "Signature verification error!"
end
