#include <filesystem/path.h>
#include <neural-graphics-primitives/testbed.h>
#include <tiny-cuda-nn/common.h>

#include <args/args.hxx>

#include <png.h>  // Add this at the top

void save_png(const std::string& filename, vec4 *image, size_t width, size_t height) {
    FILE* fp = fopen(filename.c_str(), "wb");
    if (!fp) {
        throw std::runtime_error("Failed to open PNG file for writing.");
    }

    png_structp png = png_create_write_struct(PNG_LIBPNG_VER_STRING, nullptr, nullptr, nullptr);
    png_infop info = png_create_info_struct(png);

    if (!png || !info) {
        fclose(fp);
        throw std::runtime_error("Failed to create PNG structs.");
    }

    if (setjmp(png_jmpbuf(png))) {
        png_destroy_write_struct(&png, &info);
        fclose(fp);
        throw std::runtime_error("libpng error during PNG creation.");
    }

    png_init_io(png, fp);
    png_set_IHDR(
        png,
        info,
        width,
        height,
        8,                         // Bit depth
        PNG_COLOR_TYPE_RGB,        // No alpha
        PNG_INTERLACE_NONE,
        PNG_COMPRESSION_TYPE_BASE,
        PNG_FILTER_TYPE_BASE
    );
    png_write_info(png, info);

    // Convert float vec4s to uint8 RGB
    std::vector<uint8_t> row_data(width * 3);
    for (size_t y = 0; y < height; y++) {
        for (size_t x = 0; x < width; x++) {
            size_t i = y * width + x;
            vec4 c = image[i];
            row_data[x * 3 + 0] = std::clamp(c.r * 255.0f, 0.0f, 255.0f);
            row_data[x * 3 + 1] = std::clamp(c.g * 255.0f, 0.0f, 255.0f);
            row_data[x * 3 + 2] = std::clamp(c.b * 255.0f, 0.0f, 255.0f);
        }
        png_write_row(png, row_data.data());
    }

    png_write_end(png, nullptr);
    png_destroy_write_struct(&png, &info);
    fclose(fp);
}

using namespace args;
using namespace ngp;
using namespace std;


int main()
{
  Testbed testbed;
  testbed.m_train = true;
  testbed.init_window(500, 500);
  testbed.frame();
  testbed.load_snapshot(static_cast<fs::path>(
      std::string("/home/quang/Quang/projects/fns/build/_deps/ingp-src/data/"
                  "nerf/fox_small/base.ingp")));

  testbed.frame();

  vec4* device_ptr =
      testbed.m_views.front().render_buffer.get()->frame_buffer();
  // vec4 * device_ptr = testbed.m_views.front().device->render_buffer_view().frame_buffer;
  size_t frame_width = testbed.m_views.front().full_resolution.x;
  size_t frame_height = testbed.m_views.front().full_resolution.y;

  vec4 *host_buffer = (vec4 *)malloc(sizeof(vec4) * frame_width * frame_height);

  cudaMemcpy(host_buffer,
             device_ptr,
             sizeof(vec4) * frame_width * frame_height,
             cudaMemcpyDeviceToHost);

  save_png("output.png", host_buffer, frame_width, frame_height);
  free(host_buffer);
  return 0;
}
