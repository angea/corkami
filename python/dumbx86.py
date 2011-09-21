# IDAPython cpu plugin extension
# currently buggy

import idaapi

g_description = "plugin that prevents some obsolete opcode to be created as code"
g_comment     = "Use on compiled binaries only"
g_bytecodes = [] * 256
#--------------------------------------------------------------------------
class dumbx86hook(idaapi.IDP_Hooks):
    def __init__(self):
        idaapi.IDP_Hooks.__init__(self)
        self.cmd = idaapi.cmd

    def custom_ana(self):
        b = idaapi.get_many_bytes(self.cmd.ea, 1)
        if idaapi.get_many_bytes(self.cmd.ea, 1) != "\x6a":
            pass # print "prout"
        g_bytecodes[b] += 1
        return False
        # deactivated for now

        return True


#--------------------------------------------------------------------------
class dumbx86_t(idaapi.plugin_t):
    # Processor fix plugin module
    flags = idaapi.PLUGIN_PROC | idaapi.PLUGIN_HIDE
    comment = g_comment
    wanted_hotkey = ""
    help = g_description
    wanted_name = "dumbx86"

    def init(self):
        self.prochook = None
        if idaapi.ph_get_id() != idaapi.PLFM_386:
        #    print "dumbx86_t.init() skipped!"
            return idaapi.PLUGIN_SKIP
        
        self.prochook = dumbx86hook()
        self.prochook.hook()

        print "dumbx86_t.init() called!"
        return idaapi.PLUGIN_KEEP

    def run(self, arg):
        pass

    def term(self):
        print "************* dumbx86_t.term() called!"
        if self.prochook:
            self.prochook.unhook()

#--------------------------------------------------------------------------
def PLUGIN_ENTRY():
    return dumbx86_t()
