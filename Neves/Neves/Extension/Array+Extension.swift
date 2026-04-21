//
//  Array+Extension.swift
//  Neves
//
//  Created by aa on 2026/4/7.
//

import Foundation

extension Array {
    /// 取出目标下标的元素，并从目标下标位置切割，分割左右子数组
    /// 🌰：`[1, 2, 3, 4, 5].jp_split(at: 2)` 👉🏻 `(3, [1, 2], [4, 5])`
    func jp_split(at index: Int) -> (element: Element?, left: [Element], right: [Element]) {
        if index < 0 {
            return (nil, [], self)
        }
        
        if index >= count {
            return (nil, self, [])
        }
        
        let element = self[index]
        let left = Array(self[..<index])
        let right = Array(self[(index + 1)...])
        return (element, left, right)
    }
    
    /// 随机获取x个元素组成子数组返回，子数组中的元素遵循原数组的排序
    /// 🌰：`[96, 47, 24, 664, 32, 2].jp_randomPickKeepOrder(count: 3)` 👉🏻 `[96, 24, 2]`
    func jp_randomPickKeepOrder(count x: Int) -> [Element] {
        if x <= 0 {
            return []
        }
        
        if x >= count {
            return self
        }
        
        // 1. 生成索引数组
        let indices = self.indices
        
        // 2. 打乱并取前 x 个
        let selected = indices.shuffled().prefix(x)
        
        // 3. 排序（关键！保持原顺序）
        let sortedIndices = selected.sorted()
        
        // 4. 映射回原数组
        return sortedIndices.map { self[$0] }
    }
    
    /// 获取从`start`处开始截取`length`长度的子数组
    /// 🌰：`[1, 2, 3, 4, 5, 6].jp_sub(start: 2, length: 3)` 👉🏻 `[3, 4, 5]`
    func jp_sub(start: Int, length: Int) -> [Element] {
        guard start >= 0, length > 0, start < count else {
            return []
        }
        
        let end = Swift.min(start + length, count)
        return Array(self[start..<end])
    }
}
