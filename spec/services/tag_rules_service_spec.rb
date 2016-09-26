require 'rails_helper'

describe TagRulesService do
  describe '#new' do
    it 'saves an array of tags as an array of grouped tag types' do
      tags = [{type: 1}, {type: 2}, {type: 1}]
      item_tag = double('item_tag')
      result = TagRulesService.new tags, item_tag
      expect(result.instance_variable_get(:@types)).to eq([ [{type: 1}, {type: 1}], [{type: 2}] ])
    end
  end

  describe '#find_tags' do
    context 'one tag is added' do
      it 'returns all locations from that tag' do
        tags = [{type: 1, name: 1}]
        item_tag = double('item_tag')
        search_result = [[1, 2, 3]]
        stub_search item_tag, tags, search_result
        tag_rules_service = TagRulesService.new tags, item_tag
        expect(tag_rules_service.find_tags).to eq([1, 2, 3])
      end
    end

    context 'two tags are the same type' do
      it 'merges search results of the same type' do
        tags = [{type: 1, name: 1}, {type: 1, name: 3}]
        item_tag = double('item_tag')
        search_result = [[1, 2], [3, 4]]
        stub_search item_tag, tags, search_result
        tag_rules_service = TagRulesService.new tags, item_tag
        expect(tag_rules_service.find_tags).to eq([1, 2, 3, 4])
      end

      context 'one is different' do
        it 'finds union of similar and intersection of different' do
          tags = [{type: 1, name: 1}, {type: 2, name: 2}, {type: 1, name: 3}]
          item_tag = double('item_tag')
          search_result = [[1, 2], [1, 3, 5], [3, 4]]
          stub_search item_tag, tags, search_result

          tag_rules_service = TagRulesService.new tags, item_tag
          expect(tag_rules_service.find_tags).to eq([1, 3])
        end
      end

      context 'and two of a different type' do
        it 'finds union of similar and intersection of different' do
          tags = [{type: 1, name: 1}, {type: 2, name: 2}, {type: 2, name: 3}, {type: 1, name: 4}]
          item_tag = double('item_tag')
          search_result = [[1, 2, 7], [1, 3, 5], [6, 7], [3, 4, 6]]
          stub_search item_tag, tags, search_result
          tag_rules_service = TagRulesService.new tags, item_tag
          expect(tag_rules_service.find_tags).to eq([1, 3, 6, 7])
        end
      end

    end

  end

  def stub_search(item_tag, tags, search_result)
    tags.each_with_index do |tag, index|
      allow(item_tag)
        .to receive(:find_by_tag)
        .with(tag[:name], tag[:type])
        .and_return(search_result[index])
    end
  end
end
