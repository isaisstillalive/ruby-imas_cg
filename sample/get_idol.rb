# coding: utf-8
require 'pp'
require 'json'

require_relative '../lib/imas_cg'

def puts *args
    args.map!{|arg| arg.encode Encoding::Shift_JIS, Encoding::UTF_8 }
    STDOUT.puts *args
end

idol_hashes = JSON::load(File.read('../../imas_cg_hash/hash2id.json'))
im = ImasCG['xxxx']

target_idols_name = %w{長富 大和}
idols = {}

# hashを取得
STDERR.puts 'get new hashes'
insert_idol = nil
target_idols_name.each do |key|
    im.get_gallary(key).each do |idol_data|
        im.get_gallary_description(idol_data[:index]).each do |variant|
            # 既に存在していれば飛ばす
            unless idol_hashes[variant[:hash]].nil?
                insert_idol = variant
                next
            end

            idols[variant[:hash]] = variant

            if idol_hashes[insert_idol[:hash]].nil?
                STDERR.puts '    \'%1$s\' => { name: \'%2$s\' },' % [variant[:hash], variant[:name]]
            else
                # 一連のブロックの直前のものを記録しておく
                idols[variant[:hash]][:prev_record] = insert_idol 
                STDERR.puts '    \'%1$s\' => { name: \'%2$s\', prev_record: { hash: \'%3$s\', name: \'%4$s\' } },' % [variant[:hash], variant[:name], insert_idol[:hash], insert_idol[:name]]
            end
        end
    end
end

# IDを取得
STDERR.puts 'convert hash to ID'
original_wishlist = im.get_wishlist
original_wishlist.each do |wish|
    im.remove_wishlist wish[:id]
end
idols.each_slice 3 do |rows|
    rows.each do |row|
        im.regist_wishlist row[0]
    end

    im.get_wishlist.each do |id|
        idols[id[:hash]][:id] = id[:id]
        STDERR.puts '    \'%1$s\' => { name: \'%3$s\', id: \'%2$s\' },' % [id[:hash], id[:id], idols[id[:hash]][:name]]
        im.remove_wishlist id[:id]
    end

    sleep 1
end
original_wishlist.each do |wish|
    im.regist_wishlist wish[:hash]
end

STDERR.puts 'export'
File::open('out', 'w') do |f|
    idols.each_slice 2 do |rows|
        param = [rows[0][1][:name], rows[0][0], rows[0][1][:id], rows[1][0], rows[1][1][:id]]
        f.puts "# #{rows[0][1][:prev_record][:name]}" unless rows[0][1][:prev_record].nil?
        f.puts '  "%3$s": {"id": "%3$s", "hash": "%2$s", "name": "%1$s", "next_id": "%5$s", "next_hash": "%4$s", "id_family": ["%3$s", "%5$s"], "hash_family": ["%2$s", "%4$s"]},' % param
        f.puts '  "%5$s": {"id": "%5$s", "hash": "%4$s", "name": "%1$s", "prev_id": "%3$s", "prev_hash": "%2$s", "id_family": ["%3$s", "%5$s"], "hash_family": ["%2$s", "%4$s"]},' % param
        f.puts '  "%2$s": {"id": "%3$s", "hash": "%2$s", "name": "%1$s", "next_id": "%5$s", "next_hash": "%4$s", "id_family": ["%3$s", "%5$s"], "hash_family": ["%2$s", "%4$s"]},' % param
        f.puts '  "%4$s": {"id": "%5$s", "hash": "%4$s", "name": "%1$s", "prev_id": "%3$s", "prev_hash": "%2$s", "id_family": ["%3$s", "%5$s"], "hash_family": ["%2$s", "%4$s"]},' % param
        f.puts
    end
end

