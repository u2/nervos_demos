if ARGV.length != 2
   raise "Wrong number of arguments!"
end

def hex_to_bin(s)
 if s.start_with?("0x")
    s = s[2..-1]
  end
  [s].pack("H*")
end

tx = CKB.load_tx
blake2b = Blake2b.new

 tx["inputs"].each_with_index do |input, i|
  blake2b.update(input["hash"])
  blake2b.update(input["index"].to_s)
 end
 tx["outputs"].each_with_index do |output, i|
  blake2b.update(output["capacity"].to_s)
  blake2b.update(CKB.load_script_hash(i, CKB::Source::OUTPUT, CKB::HashType::LOCK))
  if hash = CKB.load_script_hash(i, CKB::Source::OUTPUT, CKB::HashType::TYPE)
    blake2b.update(hash)
  end
 end
 hash = blake2b.final

 pubkey = ARGV[0]
 signature = ARGV[1]

 unless Secp256k1.verify(hex_to_bin(pubkey), hex_to_bin(signature), hash)
  raise "Signature verification error!"
 end