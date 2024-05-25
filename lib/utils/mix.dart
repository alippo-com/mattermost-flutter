// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

class MixinBuilder<T> {
  T superclass;
  MixinBuilder(this.superclass);

  T with1(List mixins) {
    return mixins.fold(this.superclass, (c, mixin) => mixin(c));
  }
}

MixinBuilder<T> mix<T>(T superclass) => MixinBuilder(superclass);
