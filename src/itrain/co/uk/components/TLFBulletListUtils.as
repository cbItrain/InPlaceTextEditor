package itrain.co.uk.components {
    import flashx.textLayout.edit.IEditManager;
    import flashx.textLayout.edit.SelectionState;
    import flashx.textLayout.elements.FlowGroupElement;
    import flashx.textLayout.elements.FlowLeafElement;
    import flashx.textLayout.elements.ListElement;
    import flashx.textLayout.elements.ListItemElement;
    import flashx.textLayout.elements.ParagraphElement;
    import flashx.textLayout.elements.TextFlow;

    public class TLFBulletListUtils {
        public static function handleListToggle(textFlow:TextFlow):void {
            var em:IEditManager=textFlow.interactionManager as IEditManager;
            if (em) {
                var ss:SelectionState=em.getSelectionState();
                var firstLeaf:FlowLeafElement=em.textFlow.findLeaf(ss.absoluteStart);
                var lastLeaf:FlowLeafElement=em.textFlow.findLeaf(ss.absoluteEnd);
                var listFirst:ListElement=firstLeaf.getParentByType(ListElement) as ListElement;
                var listLast:ListElement=lastLeaf.getParentByType(ListElement) as ListElement;
                em.beginCompositeOperation();
                if (!(listFirst || listLast)) { //not inside a list
                    var listItems:Array=findListItems(firstLeaf, lastLeaf);
                    if (listItems && listItems.length) { //replace whole lists with paragraphs
                        listItemsToParagraphs(listItems, textFlow);
                    } else { //replace all paragraphs between boundries with lists
                        paragraphsToLists(findParagraphs(firstLeaf, lastLeaf), textFlow);
                    }
                } else {
                    listItemsToParagraphs(findListItems(firstLeaf, lastLeaf), textFlow);
                }
                em.endCompositeOperation();
            }
        }

        /**
         * Function returns paragraphs between leaf boundries including boundries.
         */
        private static function findParagraphs(start:FlowLeafElement, end:FlowLeafElement):Array {
            var result:Array=[];
            if (start && end) {
                var paragraph:ParagraphElement=start.getParentByType(ParagraphElement) as ParagraphElement;
                if (paragraph)
                    result.push(paragraph);
                if (start != end) {
                    var currentLeaf:FlowLeafElement=start.getNextLeaf();
                    while (currentLeaf != end) {
                        paragraph=currentLeaf.getParentByType(ParagraphElement) as ParagraphElement;
                        if (paragraph && result.indexOf(paragraph) < 0)
                            result.push(paragraph);
                        currentLeaf=currentLeaf.getNextLeaf();
                    }
                    paragraph=end.getParentByType(ParagraphElement) as ParagraphElement;
                    result.push(paragraph);
                }
            }
            return result;
        }

        /**
         * Function returns list items between leaf boundries.
         */
        private static function findListItems(start:FlowLeafElement, end:FlowLeafElement):Array {
            var result:Array=[];
            if (start && end) {
                var listItem:ListItemElement=start.getParentByType(ListItemElement) as ListItemElement;
                if (listItem)
                    result.push(listItem);
                if (start != end) {
                    var currentLeaf:FlowLeafElement=start.getNextLeaf();
                    while (currentLeaf != end) {
                        listItem=currentLeaf.getParentByType(ListItemElement) as ListItemElement;
                        if (listItem && result.indexOf(listItem) < 0)
                            result.push(listItem);
                        currentLeaf=currentLeaf.getNextLeaf();
                    }
                    listItem=end.getParentByType(ListItemElement) as ListItemElement;
                    if (listItem && result.indexOf(listItem) < 0)
                        result.push(listItem);
                }
            }
            return result;
        }

        /**
         * Function converts a single list item to a paragraph.
         */
        private static function listItemsToParagraphs(listItems:Array, textFlow:TextFlow):void {
            if (listItems && listItems.length) {
                var parentList:ListElement;
                var sameParent:Array=[];
                for each (var li:ListItemElement in listItems) {
                    if (li.parent != parentList) {
                        parseListItem(sameParent, parentList, textFlow);
                        parentList=li.parent as ListElement;
                        sameParent=[li];
                    } else {
                        sameParent.push(li);
                    }
                }
                parseListItem(sameParent, parentList, textFlow);
            }
        }

        private static function parseListItem(sameParent:Array, parentList:ListElement, textFlow:TextFlow):void {
            if (sameParent.length) {
                var parentContainer:FlowGroupElement=parentList.parent as FlowGroupElement;
                if (parentList.numChildren == sameParent.length) { //do not split list
                    convertListItemsAndInsert(sameParent, parentContainer, parentContainer.getChildIndex(parentList));
                    parentContainer.removeChild(parentList);
                } else { // split list
                    var firstItemIndex:int=parentList.getChildIndex(sameParent[0]);
                    if (firstItemIndex == 0) { //remove from beginning
                        convertListItemsAndInsert(sameParent, parentContainer, parentContainer.getChildIndex(parentList));
                    } else {
                        var lastItemIndex:int=parentList.getChildIndex(sameParent[sameParent.length - 1]);
                        var insertionIndex:int=parentContainer.getChildIndex(parentList) + 1;
                        if (lastItemIndex == parentList.numChildren - 1) { //remove from the end
                            convertListItemsAndInsert(sameParent, parentContainer, insertionIndex);
                        } else { //remove from the middle
                            var tailItems:Array=getListItemsFromIndex(lastItemIndex + 1, parentList);
                            var lastInsertIndex:int=convertListItemsAndInsert(sameParent, parentContainer, insertionIndex);
                            var fLeaf:FlowLeafElement=(parentContainer.getChildAt(insertionIndex) as ParagraphElement).getFirstLeaf();
                            var lLeaf:FlowLeafElement=(parentContainer.getChildAt(lastInsertIndex) as ParagraphElement).getLastLeaf();
                            paragraphsToLists(findParagraphs(fLeaf, lLeaf), textFlow);
                        }
                    }
                }
            }
        }

        /**
         * Function gets the list items beginning from the start index up to the end of the list.
         */
        private static function getListItemsFromIndex(startIndex:int, list:ListElement):Array {
            var result:Array=[];
            if (startIndex > 0 && startIndex < list.numChildren) {
                for (var i:int=startIndex; i < list.numChildren; i++) {
                    result.push(list.getChildAt(i));
                }
            }
            return result;
        }

        /**
         * Function removes contents of the li element and adds it to the parent container at specified index.
         * @return - index of the last inserted element.
         */
        private static function convertListItemsAndInsert(listItems:Array, parentContainer:FlowGroupElement, insertIndex:int):int {
            var index:int=insertIndex;
            for each (var li:ListItemElement in listItems) {
                li.parent.removeChild(li);
                for (var i:int=0; i < li.numChildren; i++) {
                    parentContainer.addChildAt(index, li.getChildAt(i));
                    index++;
                }
            }
            return index - 1;
        }

        /**
         * Function creates lists between given boundries.
         */
        private static function paragraphsToLists(paragraphs:Array, textFlow:TextFlow):void {
            if (paragraphs && paragraphs.length) {
                var em:IEditManager=textFlow.interactionManager as IEditManager;
                var fp:ParagraphElement=paragraphs[0] as ParagraphElement;
                var lp:ParagraphElement=paragraphs[paragraphs.length - 1] as ParagraphElement;
                var newSelectionState:SelectionState=new SelectionState(textFlow, fp.getAbsoluteStart(), lp.getAbsoluteStart() + lp.getText().length + 1);
                em.createList(null, em.getCommonCharacterFormat(), newSelectionState);
            }
        }

        public static function containsLists(textFlow:TextFlow):Boolean {
            var em:IEditManager=textFlow.interactionManager as IEditManager;
            var result:Boolean=false;
            if (em) {
                var ss:SelectionState=em.getSelectionState();
                var firstLeaf:FlowLeafElement=em.textFlow.findLeaf(ss.absoluteStart);
                var lastLeaf:FlowLeafElement=em.textFlow.findLeaf(ss.absoluteEnd);
                var listFirst:ListElement=firstLeaf.getParentByType(ListElement) as ListElement;
                var listLast:ListElement=lastLeaf.getParentByType(ListElement) as ListElement;
                if (!(listFirst || listLast)) { //not inside a list
                    var listItems:Array=findListItems(firstLeaf, lastLeaf);
                    if (listItems && listItems.length) { //enable lists
                        result=true;
                    }
                } else { //enable lists
                    result=true;
                }
            }
            return result;
        }
    }
}
