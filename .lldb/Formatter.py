import lldb
import sys
import traceback

class Collection_SyntheticProvider:
    def __init__(self, valobj, internal_dict):
        self.valobj = valobj

    def num_children(self):
        try:
            s = self.valobj.GetChildMemberWithName('size').GetValueAsUnsigned()
            return s
        except:
            return 0

    def get_child_index(self,name):
        try:
            return int(name.lstrip('[').rstrip(']'))
        except:
            return None

    def get_child_at_index(self,index):
        if index < 0:
            return None
        if index >= self.num_children():
            return None
        if self.valobj.IsValid() == False:
            return None
        try:
            type = self.valobj.GetChildMemberWithName('data').GetType().GetPointeeType()
            elementSize = type.GetByteSize()
            return self.valobj.GetChildMemberWithName('data').CreateChildAtOffset('[' + str(index) + ']', index * elementSize, type)
        except:
            return None


class Node_SyntheticProvider:
    def __init__(self, valobj, internal_dict):
        self.valobj = valobj

    def num_children(self):
        try:
            s = self.valobj.GetChildMemberWithName('size').GetValueAsUnsigned()+2
            return s
        except:
            return 0

    def get_child_index(self,name):
        try:
            print(name)
            return int(name.lstrip('[').rstrip(']'))
        except:
            return None

    def get_child_at_index(self,index):
        if index < 0:
            return None
        if index >= self.num_children():
            return None
        if self.valobj.IsValid() == False:
            return None
        try:
            if index == 0:
                return self.valobj.GetChildMemberWithName('key')
            elif index == 1:
                return self.valobj.GetChildMemberWithName('value')
            else:
                index = index - 2
                type = self.valobj.GetChildMemberWithName('subnodes').GetType().GetPointeeType()
                elementSize = type.GetByteSize()
                return self.valobj.GetChildMemberWithName('subnodes').CreateChildAtOffset('[' + str(index) + ']', index * elementSize, type)
        except:
            return None
