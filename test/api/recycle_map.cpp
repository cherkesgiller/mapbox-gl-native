#include <mbgl/test/util.hpp>
#include <mbgl/test/stub_file_source.hpp>

#include <mbgl/gl/headless_frontend.hpp>
#include <mbgl/map/map.hpp>
#include <mbgl/renderer/backend_scope.hpp>
#include <mbgl/storage/online_file_source.hpp>
#include <mbgl/style/layers/line_layer.hpp>
#include <mbgl/style/layers/symbol_layer.hpp>
#include <mbgl/style/sources/geojson_source.hpp>
#include <mbgl/style/image.hpp>
#include <mbgl/style/style.hpp>
#include <mbgl/style/observer.hpp>
#include <mbgl/util/default_thread_pool.hpp>
#include <mbgl/util/exception.hpp>
#include <mbgl/util/geometry.hpp>
#include <mbgl/util/geojson.hpp>
#include <mbgl/util/io.hpp>
#include <mbgl/util/run_loop.hpp>

using namespace mbgl;
using namespace mbgl::style;


TEST(API, RecycleMapUpdateImages) {
    util::RunLoop loop;

    StubFileSource fileSource;
    ThreadPool threadPool(4);
    float pixelRatio { 1 };

    HeadlessFrontend frontend { pixelRatio, fileSource, threadPool };
    auto map = std::make_unique<Map>(frontend, MapObserver::nullObserver(), frontend.getSize(),
                                     pixelRatio, fileSource, threadPool, MapMode::Still);

    EXPECT_TRUE(map);

    auto loadStyle = [&](auto markerName, auto markerPath) {
        auto source = std::make_unique<GeoJSONSource>("geometry");
        source->setGeoJSON({ Point<double> { 0, 0 } });

        auto layer = std::make_unique<SymbolLayer>("geometry", "geometry");
        layer->setIconImage({ markerName });

        map->getStyle().loadJSON(util::read_file("test/fixtures/api/empty.json"));
        map->getStyle().addSource(std::move(source));
        map->getStyle().addLayer(std::move(layer));
        map->getStyle().addImage(std::make_unique<style::Image>(markerName, decodeImage(util::read_file(markerPath)), 1.0));
    };

    // default marker

    loadStyle("default_marker", "test/fixtures/sprites/default_marker.png");
    test::checkImage("test/fixtures/recycle_map/default_marker", frontend.render(*map), 0.0006, 0.1);

    // flipped marker

    loadStyle("flipped_marker", "test/fixtures/sprites/flipped_marker.png");
    test::checkImage("test/fixtures/recycle_map/flipped_marker", frontend.render(*map), 0.0006, 0.1);
}

TEST(API, RecycleMapRefreshRenderTileLayers) {
    util::RunLoop loop;

    StubFileSource fileSource;
    ThreadPool threadPool(4);
    float pixelRatio { 1 };

    HeadlessFrontend frontend { pixelRatio, fileSource, threadPool };
    auto map = std::make_unique<Map>(frontend, MapObserver::nullObserver(), frontend.getSize(),
                                     pixelRatio, fileSource, threadPool, MapMode::Still);

    EXPECT_TRUE(map);

    map->setLatLngZoom({ 0, 0 }, 10);

    map->getStyle().loadJSON(util::read_file("test/fixtures/api/empty.json"));

    auto source = std::make_unique<GeoJSONSource>("source");
    source->setGeoJSON({ LineString<double> { { -45, -45 }, { 45, 45 } }});
    map->getStyle().addSource(std::move(source));

    auto symbol = std::make_unique<SymbolLayer>("symbol", "source");
    map->getStyle().addLayer(std::move(symbol));

    // Retain render tile at given position.
    frontend.render(*map);

    map->setLatLngZoom({ 45, 45 }, 12);

    auto layer = std::make_unique<LineLayer>("line", "source");
    layer->setLineColor({ mbgl::Color::red() });
    map->getStyle().addLayer(std::move(layer));

    // Now add a new layer and use non-cached/retained tiles.
    frontend.render(*map);

    map->setLatLngZoom({ 0, 0 }, 10);

    // Removing a layer should enforce relayout in the previous cached/retained
    // tile from the same position.
    test::checkImage("test/fixtures/recycle_map/red_line", frontend.render(*map), 0.0006, 0.1);
}
