make confclean
# CXXFLAGS="_GLIBCXX_USE_CXX11_ABI=0 -std=gnu++98" 
#./configure -glib -nomake examples -nomake demos -nomake docs -prefix /opt/qt-everywhere-4.8.7 -debug -opensource -shared -no-openssl -no-webkit -no-opengl -no-qt3support -no-javascript-jit
./configure -glib -fontconfig -nomake examples -nomake demos -nomake docs -prefix /opt/qt-everywhere-4.8.7 -debug -opensource -shared -no-openssl -no-javascript-jit
#make -j8
