require_relative "ckb-sdk-ruby/lib/ckb.rb"
require_relative "ckb-sdk-ruby/lib/api"
require_relative "ckb-sdk-ruby/lib/always_success_wallet"
require_relative "ckb-sdk-ruby/lib/utils"
require_relative "ckb-sdk-ruby/lib/version"
require_relative "ckb-sdk-ruby/lib/blake2b"

LOCK_SCRIPT = File.read(File.expand_path("../../../scripts/sighash_all.rb", __FILE__))

class Wallet
	      attr_reader :api
   	  attr_reader :privkey
    # initialize wallet with private key and api object
    def initialize(api, privkey)
      unless privkey.instance_of?(String) && privkey.size == 32
       raise ArgumentError, "invalid privkey!"
      end
     @api = api
     @privkey = privkey
   end

  def get_unspent_cells
    to = api.get_tip_number
    results = []
    current_from = 1
    while current_from <= to
      current_to = [current_from + 100, to].min
      cells = api.get_cells_by_lock_hash(verify_script_hash, current_from, current_to)
      results.concat(cells)
      current_from = current_to + 1
   end
  results
  end

  def get_balance
     get_unspent_cells.map { |c| c[:capacity] }.reduce(0, &:+)
  end

  def pubkey_bin
    Ckb::Utils.extract_pubkey_bin(privkey)
   end

  def pubkey_hash_bin
    Ckb::Blake2b.digest(Ckb::Blake2b.digest(pubkey_bin))
  end

 def verify_script_json_object
    {
      binary_hash: api.mruby_cell_hash,
      args: [
        Ckb::Utils.bin_to_hex(pubkey_hash_bin)
      ]
    }
  end
end
