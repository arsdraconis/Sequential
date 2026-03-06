//
//  NSTableColumn+Extensions.swift
//  Sequential
//
//  Created by nulldragon on 2026-03-06.
//

extension NSTableColumn
{
    func sizeToFitLongestContent()
    {
        guard resizingMask != [],
        let tableView = self.tableView,
        let columnIndex = tableView.tableColumns.firstIndex(of: self) else
        {
            return
        }
        
        var width: CGFloat = 0.0
        for rowIndex in 0 ..< tableView.numberOfRows
        {
            let view = tableView.view(atColumn: columnIndex, row: rowIndex, makeIfNecessary: true)!
            width = max(width, view.fittingSize.width)
        }
        
        self.width = min(max(ceil(width + 3.0), minWidth), maxWidth)
    }
}
