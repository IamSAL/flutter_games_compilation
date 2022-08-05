import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_learn_flame/lesson_07/objects/object_state.dart';
import 'package:flutter_learn_flame/my_game.dart';

import '../game_lesson_07.dart';

class Ball extends BodyComponent with ContactCallbacks {
  final size = Vector2(.5, .5);
  ObjectState state = ObjectState.normal;

  late final SpriteComponent normalComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;
    final sprite = Sprite(gameRef.images.fromCache('ball.png'));

    normalComponent = SpriteComponent(
      sprite: sprite,
      size: Vector2(.5, .5),
      anchor: Anchor.center,
    );

    add(normalComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (state == ObjectState.explode) {
      world.destroyBody(body);
      gameRef.remove(this);
    }
  }

  void hit() {
    if (state == ObjectState.normal) {
      state = ObjectState.explode;
      remove(normalComponent);
      gameRef.add(SpriteAnimationComponent(
        position: body.position,
        animation: explosion.clone(),
        anchor: Anchor.center,
        size: size,
        removeOnFinish: true,
      ));
    }
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      userData: this,
      position: Vector2(worldSize.x / 2, 0),
      type: BodyType.dynamic,
    );

    final shape = CircleShape()..radius = .25;
    final fixtureDef = FixtureDef(shape)
      ..density = 5
      ..friction = .5
      ..restitution = .5;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Ball) {
      hit();
    }
  }
}
