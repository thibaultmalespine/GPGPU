if (NOT EXISTS "/home/thibault/Documents/Etude/Master Informatique/S8/GPGPU/TP2/TP2-Ex1-Mandelbrot-Renderer-20260306/out/install_manifest.txt")
    message(FATAL_ERROR "Cannot find install manifest: \"/home/thibault/Documents/Etude/Master Informatique/S8/GPGPU/TP2/TP2-Ex1-Mandelbrot-Renderer-20260306/out/install_manifest.txt\"")
endif(NOT EXISTS "/home/thibault/Documents/Etude/Master Informatique/S8/GPGPU/TP2/TP2-Ex1-Mandelbrot-Renderer-20260306/out/install_manifest.txt")

file(READ "/home/thibault/Documents/Etude/Master Informatique/S8/GPGPU/TP2/TP2-Ex1-Mandelbrot-Renderer-20260306/out/install_manifest.txt" files)
string(REGEX REPLACE "\n" ";" files "${files}")
foreach (file ${files})
    message(STATUS "Uninstalling \"$ENV{DESTDIR}${file}\"")
    execute_process(
        COMMAND /usr/bin/cmake -E remove "$ENV{DESTDIR}${file}"
        OUTPUT_VARIABLE rm_out
        RESULT_VARIABLE rm_retval
    )
    if(NOT ${rm_retval} EQUAL 0)
        message(FATAL_ERROR "Problem when removing \"$ENV{DESTDIR}${file}\"")
    endif (NOT ${rm_retval} EQUAL 0)
endforeach(file)

